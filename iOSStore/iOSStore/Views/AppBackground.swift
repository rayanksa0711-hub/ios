//
//  AppBackground.swift
//  iOSStore
//

import SwiftUI

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }
}
