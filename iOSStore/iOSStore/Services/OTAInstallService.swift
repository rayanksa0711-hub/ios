//
//  OTAInstallService.swift
//  iOSStore
//

import Foundation
import UIKit

/// Service that prepares and triggers Over-The-Air iOS app installation.
///
/// iOS OTA installation requires a signed `.ipa` file served over HTTPS and a
/// `manifest.plist` file describing the bundle. The device reads the manifest
/// through the `itms-services://?action=download-manifest&url=...` URL scheme.
///
/// Note: The manifest must be served from a publicly reachable HTTPS URL with a
/// valid certificate. This service can either:
///   1. Generate a manifest locally and upload it to R2 (recommended), or
///   2. Point to a pre-generated manifest that already exists in R2.
final class OTAInstallService {
    static let shared = OTAInstallService()

    private init() {}

    /// Triggers the iOS install flow for a given store item.
    ///
    /// - Parameters:
    ///   - item: The `StoreItem` to install.
    ///   - manifestBaseURL: Optional HTTPS URL where the manifest file is hosted.
    ///     If nil, the service assumes a manifest named `<bundle_id>.plist`
    ///     exists at the root of the R2 bucket.
    func install(_ item: StoreItem, manifestBaseURL: URL? = nil) {
        let manifestURL = manifestBaseURL ?? fallbackManifestURL(for: item)

        guard let encodedManifestURL = manifestURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            presentAlert(message: NSLocalizedString("Unable to encode manifest URL", comment: ""))
            return
        }

        let itmsURLString = "itms-services://?action=download-manifest&url=\(encodedManifestURL)"
        guard let itmsURL = URL(string: itmsURLString) else {
            presentAlert(message: NSLocalizedString("Invalid install URL", comment: ""))
            return
        }

        if UIApplication.shared.canOpenURL(itmsURL) {
            UIApplication.shared.open(itmsURL, options: [:]) { success in
                if !success {
                    self.presentAlert(message: NSLocalizedString("Installation could not be started", comment: ""))
                }
            }
        } else {
            presentAlert(message: NSLocalizedString("OTA install is not available on this device", comment: ""))
        }
    }

    /// Generates a complete `manifest.plist` XML string for a store item.
    ///
    /// Use this output to upload a `.plist` file next to your `.ipa` in R2, or
    /// serve it from a tiny backend endpoint.
    func generateManifestPlist(for item: StoreItem) -> String {
        let ipaURLString = item.ipaURL?.absoluteString ?? ""
        let iconURLString = item.iconURL?.absoluteString ?? ""

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>items</key>
            <array>
                <dict>
                    <key>assets</key>
                    <array>
                        <dict>
                            <key>kind</key>
                            <string>software-package</string>
                            <key>url</key>
                            <string>\(escaped(ipaURLString))</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>display-image</string>
                            <key>url</key>
                            <string>\(escaped(iconURLString))</string>
                        </dict>
                        <dict>
                            <key>kind</key>
                            <string>full-size-image</string>
                            <key>url</key>
                            <string>\(escaped(iconURLString))</string>
                        </dict>
                    </array>
                    <key>metadata</key>
                    <dict>
                        <key>bundle-identifier</key>
                        <string>\(escaped(item.bundleIdentifier))</string>
                        <key>bundle-version</key>
                        <string>\(escaped(item.version))</string>
                        <key>kind</key>
                        <string>software</string>
                        <key>title</key>
                        <string>\(escaped(item.name))</string>
                    </dict>
                </dict>
            </array>
        </dict>
        </plist>
        """
    }

    /// Produces a manifest file locally (for debugging or AirDrop sharing).
    func writeManifestToTempDirectory(for item: StoreItem) throws -> URL {
        let plist = generateManifestPlist(for: item)
        let fileName = "\(item.bundleIdentifier).plist"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try plist.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Private helpers

    private func fallbackManifestURL(for item: StoreItem) -> URL {
        R2Service.shared.baseURL
            .appendingPathComponent("manifests")
            .appendingPathComponent("\(item.bundleIdentifier).plist")
    }

    private func escaped(_ string: String) -> String {
        string.replacingOccurrences(of: "&", with: "&amp;")
              .replacingOccurrences(of: "<", with: "&lt;")
              .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func presentAlert(message: String) {
        DispatchQueue.main.async {
            guard let rootVC = Self.topMostViewController() else { return }
            let alert = UIAlertController(
                title: NSLocalizedString("Install", comment: ""),
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            rootVC.present(alert, animated: true)
        }
    }

    private static func topMostViewController() -> UIViewController? {
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
