//
//  AppDetailView.swift
//  iOSStore
//

import SwiftUI

struct AppDetailView: View {
    let item: StoreItem
    @State private var isInstalling = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                Divider()
                    .background(Color.appBorder)
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
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: item.iconURL) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(ProgressView().tint(.appAccent))
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.appSurface)
                        .overlay(Image(systemName: "app").foregroundColor(.appTextSecondary))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: Color.appAccent.opacity(0.25), radius: 16, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.appTextPrimary)
                    .lineLimit(2)

                Text(item.developer)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.appTextSecondary)

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
                        .tint(.appBackground)
                        .scaleEffect(0.8)
                }

                Text(isInstalling
                     ? NSLocalizedString("Installing...", comment: "")
                     : NSLocalizedString("INSTALL", comment: ""))
                    .font(.system(size: 14, weight: .bold, design: .default))
            }
            .foregroundColor(.appBackground)
            .frame(width: 120, height: 34)
            .background(
                Capsule()
                    .fill(LinearGradient.appAccentGradient)
            )
            .shadow(color: Color.appAccent.opacity(0.4), radius: 8, x: 0, y: 3)
        }
        .disabled(isInstalling)
    }

    private var metadataSection: some View {
        HStack(spacing: 0) {
            metadataCell(title: NSLocalizedString("Version", comment: ""), value: item.version)
            Divider().background(Color.appBorder)
            metadataCell(title: NSLocalizedString("Size", comment: ""), value: item.formattedSize)
            Divider().background(Color.appBorder)
            metadataCell(title: NSLocalizedString("Category", comment: ""), value: item.localizedCategory)
        }
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.appBorder, lineWidth: 1)
                )
        )
    }

    private func metadataCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(.appAccent)

            Text(title)
                .font(.system(size: 11, weight: .regular, design: .default))
                .foregroundColor(.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var descriptionBody: some View {
        Text(item.description)
            .font(.system(size: 16, weight: .regular, design: .default))
            .foregroundColor(.appTextPrimary)
            .lineSpacing(4)
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("About", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.appTextPrimary)

            descriptionBody
        }
    }

    private func telegramSection(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("From Telegram", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.appTextPrimary)

            Text(text)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(.appTextSecondary)
                .lineSpacing(4)
        }
    }

    private var screenshotsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("Preview", comment: ""))
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.appTextPrimary)
                .padding(.horizontal, 16)

            if item.screenshots.isEmpty {
                Text(NSLocalizedString("No screenshots available", comment: ""))
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.appTextSecondary)
                    .padding(.horizontal, 16)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(item.screenshots, id: \.self) { url in
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.appSurface)
                                        .frame(width: 180, height: 320)
                                        .overlay(ProgressView().tint(.appAccent))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.appSurface)
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
                .foregroundColor(.appAccent)
        }
        .disabled(item.ipaURL == nil)
    }

    private func beginInstall() {
        isInstalling = true
        OTAInstallService.shared.install(item)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isInstalling = false
        }
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
