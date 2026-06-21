//
//  iOSStoreApp.swift
//  iOSStore
//
//  iOS App Store client with native SwiftUI design,
//  Cloudflare R2 integration, and OTA install support.
//

import SwiftUI

@main
struct iOSStoreApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storeVM = StoreViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(storeVM)
                .preferredColorScheme(.none)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Use SF Pro system font globally (no custom font registration needed).
        return true
    }
}
