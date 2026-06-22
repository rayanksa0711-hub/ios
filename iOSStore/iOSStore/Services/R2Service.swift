//
//  R2Service.swift
//  iOSStore
//

import Foundation

/// Errors that can occur while communicating with Cloudflare R2.
enum R2ServiceError: Error, LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case decodeFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return NSLocalizedString("Invalid R2 public URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from R2", comment: "")
        case .decodeFailed(let error):
            return String(format: NSLocalizedString("Decode failed: %@", comment: ""), error.localizedDescription)
        }
    }
}

/// Service responsible for fetching store metadata from Cloudflare R2.
///
/// The bucket is expected to expose a `store.json` file at the root of the public URL.
/// Example structure:
/// {
///   "items": [
///     {
///       "id": "com.example.game",
///       "name": "Example Game",
///       "developer": "Example Dev",
///       "category": "game",
///       "description": "Short description",
///       "icon_url": "https://pub-...r2.dev/icons/game.png",
///       "ipa_url": "https://pub-...r2.dev/ipas/game.ipa",
///       "bundle_id": "com.example.game",
///       "version": "1.0.0",
///       "size_bytes": 67108864,
///       "screenshots": [],
///       "telegram_description": "Long description pulled from Telegram"
///     }
///   ]
/// }
final class R2Service {
    static let shared = R2Service()

    /// Public R2 bucket URL. Override via Info.plist key `R2_PUBLIC_URL`.
    private(set) var baseURL: URL

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session

        if let infoURLString = Bundle.main.object(forInfoDictionaryKey: "R2_PUBLIC_URL") as? String,
           let infoURL = URL(string: infoURLString) {
            self.baseURL = infoURL
        } else {
            // Fallback placeholder. Replace with your actual R2 public URL.
            self.baseURL = URL(string: "https://pub-xxxxxxxxxxxxxxxxxxxxxxxxxxxx.r2.dev")!
        }
    }

    /// Convenience URL for the catalog JSON.
    var catalogURL: URL {
        baseURL.appendingPathComponent("store.json")
    }

    /// Fetches the catalog of apps/games.
    func fetchCatalog() async throws -> [StoreItem] {
        let (data, response) = try await session.data(from: catalogURL)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw R2ServiceError.invalidResponse
        }

        do {
            let catalog = try JSONDecoder().decode(CatalogResponse.self, from: data)
            return catalog.items
        } catch {
            throw R2ServiceError.decodeFailed(error)
        }
    }

    /// Resolves a relative path against the R2 base URL.
    func resolveURL(path: String) -> URL {
        baseURL.appendingPathComponent(path)
    }
}

private struct CatalogResponse: Codable {
    let items: [StoreItem]
}
