//
//  BlurTabBar.swift
//  iOSStore
//

import SwiftUI

/// Configures the system tab bar to match the premium dark theme.
struct BlurTabBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
                appearance.backgroundColor = UIColor(Color.appCardBackground).withAlphaComponent(0.85)

                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.appTextSecondary)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.appTextSecondary)
                ]
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appAccent)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.appAccent)
                ]

                UITabBar.appearance().standardAppearance = appearance
                if #available(iOS 15.0, *) {
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
    }
}

extension View {
    func themedTabBar() -> some View {
        modifier(BlurTabBar())
    }
}
