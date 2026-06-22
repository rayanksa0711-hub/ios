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

            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(1)

                Text(item.developer)
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.appTextSecondary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    tagView(text: item.version)
                    tagView(text: item.formattedSize)
                    tagView(text: item.localizedCategory)
                }
            }

            Spacer()

            getButton
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }

    private var iconView: some View {
        Group {
            if let url = item.iconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderIcon
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderIcon
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                placeholderIcon
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var placeholderIcon: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient.appAccentGradient.opacity(0.2))
            .overlay(
                Text(item.iconPlaceholderLetter)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.appAccent)
            )
    }

    private func tagView(text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .default))
            .foregroundColor(.appTextSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.appSurface)
            )
            .overlay(
                Capsule()
                    .stroke(Color.appBorder.opacity(0.5), lineWidth: 0.5)
            )
    }

    private var getButton: some View {
        Text(NSLocalizedString("GET", comment: ""))
            .font(.system(size: 13, weight: .bold, design: .default))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(LinearGradient.appAccentGradient)
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
        .background(Color.appBackground)
        .previewLayout(.sizeThatFits)
    }
}
