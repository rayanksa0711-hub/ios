//
//  StoreViewModel.swift
//  iOSStore
//

import Foundation
import Combine

@MainActor
final class StoreViewModel: ObservableObject {
    @Published var items: [StoreItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let r2Service: R2Service

    init(r2Service: R2Service = .shared) {
        self.r2Service = r2Service
    }

    var games: [StoreItem] {
        items.filter { $0.category == .game }
    }

    var apps: [StoreItem] {
        items.filter { $0.category == .app }
    }

    var featured: [StoreItem] {
        Array(items.prefix(6))
    }

    func loadCatalog() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            items = try await r2Service.fetchCatalog()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func item(withID id: String) -> StoreItem? {
        items.first { $0.id == id }
    }
}

#if DEBUG
extension StoreViewModel {
    static var preview: StoreViewModel {
        let vm = StoreViewModel()
        vm.items = [
            StoreItem(
                id: "com.example.game1",
                name: "Turbo Racer",
                developer: "Speed Studio",
                category: .game,
                description: "High-speed arcade racing with native iOS controls.",
                iconURL: URL(string: "https://example.com/icon.png"),
                ipaURL: URL(string: "https://example.com/app.ipa"),
                bundleIdentifier: "com.example.game1",
                version: "1.0",
                sizeBytes: 64_000_000,
                screenshots: [],
                telegramDescription: "Race through neon cities in this premium arcade racer."
            ),
            StoreItem(
                id: "com.example.app1",
                name: "Focus Timer",
                developer: "Productivity Co",
                category: .app,
                description: "A minimalist focus timer for deep work sessions.",
                iconURL: URL(string: "https://example.com/icon2.png"),
                ipaURL: URL(string: "https://example.com/app2.ipa"),
                bundleIdentifier: "com.example.app1",
                version: "2.1",
                sizeBytes: 24_000_000,
                screenshots: [],
                telegramDescription: "Pomodoro timer with analytics and iCloud sync."
            )
        ]
        return vm
    }
}
#endif
