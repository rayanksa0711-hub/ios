//
//  AppDetailView.swift
//  iOSStore
//

import SwiftUI

struct AppDetailView: View {
    let item: StoreItem
    @State private var isInstalling = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                metadataSection
                    .padding(.horizontal, 16)

                descriptionSection
                    .padding(.horizontal, 16)
                    .padding(.top, 24)

                if let telegram = item.telegramDescription, !telegram.isEmpty {
                    telegramSection(text: telegram)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                }

                screenshotsSection
                    .padding(.top, 24)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: item.iconURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(.tertiarySystemFill))
                        .overlay(Image(systemName: "app").foregroundColor(.secondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(item.developer)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.secondary)

                Spacer(minLength: 10)

                installButton
            }
        }
        .frame(height: 130)
    }

    private var installButton: some View {
        Button(action: beginInstall) {
            HStack(spacing: 6) {
                if isInstalling {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                }

                Text(isInstalling
                     ? NSLocalizedString("Installing...", comment: "")
                     : NSLocalizedString("INSTALL", comment: ""))
                    .font(.system(size: 14, weight: .bold, design: .default))
            }
            .foregroundColor(.white)
            .frame(width: 120, height: 34)
            .background(
                Capsule()
                    .fill(Color.blue)
            )
        }
        .disabled(isInstalling)
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        HStack(spacing: 0) {
            metadataCell(title: NSLocalizedString("Version", comment: ""), value: item.version)
            Divider()
            metadataCell(title: NSLocalizedString("Size", comment: ""), value: item.formattedSize)
            Divider()
            metadataCell(title: NSLocalizedString("Category", comment: ""), value: item.localizedCategory)
        }
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func metadataCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(.primary)

            Text(title)
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Description

    private var descriptionBody: some View {
        Text(item.description)
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundColor(.primary)
            .lineSpacing(4)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("About", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primary)

            descriptionBody
        }
    }

    private func telegramSection(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("From Telegram", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primary)

            Text(text)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Screenshots

    private var screenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Preview", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)

            if item.screenshots.isEmpty {
                Text(NSLocalizedString("No screenshots available", comment: ""))
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(item.screenshots, id: \.self) { url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 180, height: 320)
                                        .overlay(ProgressView())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(width: 180, height: 320)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 180, height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private var shareButton: some View {
        Button(action: {
            guard let url = item.ipaURL else { return }
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let rootVC = topMostViewController() {
                rootVC.present(activity, animated: true)
            }
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(item.ipaURL == nil)
    }

    private func topMostViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    // MARK: - Actions

    private func beginInstall() {
        isInstalling = true
        OTAInstallService.shared.install(item)

        // Reset the spinner after a short delay so the user can retry if needed.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isInstalling = false
        }
    }
}

struct AppDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AppDetailView(item: StoreItem(
            id: "preview",
            name: "Preview App",
            developer: "Preview Dev",
            category: .app,
            description: "This is a sample app description.",
            iconURL: nil,
            ipaURL: nil,
            bundleIdentifier: "com.preview.app",
            version: "1.0.0",
            sizeBytes: 50_000_000,
            screenshots: [],
            telegramDescription: "Longer description from Telegram."
        ))
    }
}
