//
//  StoreItem.swift
//  iOSStore
//

import Foundation

enum StoreItemCategory: String, Codable, CaseIterable {
    case game = "game"
    case app = "app"
}

struct StoreItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let developer: String
    let category: StoreItemCategory
    let description: String
    let iconURL: URL?
    let ipaURL: URL?
    let bundleIdentifier: String
    let version: String
    let sizeBytes: Int64?
    let screenshots: [URL]
    let telegramDescription: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case developer
        case category
        case description
        case iconURL = "icon_url"
        case ipaURL = "ipa_url"
        case bundleIdentifier = "bundle_id"
        case version
        case sizeBytes = "size_bytes"
        case screenshots
        case telegramDescription = "telegram_description"
    }
}

extension StoreItem {
    var iconPlaceholderLetter: String {
        String(name.prefix(1)).uppercased()
    }

    var localizedCategory: String {
        switch category {
        case .game:
            return NSLocalizedString("Games", comment: "")
        case .app:
            return NSLocalizedString("Apps", comment: "")
        }
    }

    var formattedSize: String {
        guard let bytes = sizeBytes, bytes > 0 else { return "--" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
