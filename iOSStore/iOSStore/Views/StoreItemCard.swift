//
//  StoreItemCard.swift
//  iOSStore
//

import SwiftUI

struct StoreItemCard: View {
    let item: StoreItem

    var body: some View {
        HStack(spacing: 14) {
            iconView

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(item.developer)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(item.version)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(item.formattedSize)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            installButtonLabel
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    private var iconView: some View {
        AsyncImage(url: item.iconURL) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
                    .overlay(ProgressView())
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemFill))
                    .overlay(Image(systemName: "app").foregroundColor(.secondary))
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var installButtonLabel: some View {
        Text(NSLocalizedString("GET", comment: ""))
            .font(.system(size: 14, weight: .bold, design: .default))
            .foregroundColor(.blue)
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.tertiarySystemFill))
            )
    }
}

struct StoreItemCard_Previews: PreviewProvider {
    static var previews: some View {
        StoreItemCard(item: StoreItem(
            id: "preview",
            name: "Sample App",
            developer: "Preview Dev",
            category: .app,
            description: "Short description",
            iconURL: nil,
            ipaURL: nil,
            bundleIdentifier: "com.preview.app",
            version: "1.0",
            sizeBytes: 45_000_000,
            screenshots: [],
            telegramDescription: nil
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
