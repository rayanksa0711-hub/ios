//
//  BlurTabBar.swift
//  iOSStore
//

import SwiftUI

/// Configures the system tab bar to use a frosted-glass / blur background.
struct BlurTabBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
                appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)

                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
    }
}

extension View {
    func frostedTabBar() -> some View {
        modifier(BlurTabBar())
    }
}
