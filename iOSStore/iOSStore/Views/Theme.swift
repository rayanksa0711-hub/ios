//
//  Theme.swift
//  iOSStore
//

import SwiftUI

/// Official LOGIC STORE brand colors.
extension Color {
    /// Midnight navy blue - backgrounds, fields, frames, core UI.
    static let appBackground = Color(hex: "#002855")

    /// Slightly lighter navy for cards and surfaces.
    static let appCardBackground = Color(hex: "#003366")

    /// Elevated card surface.
    static let appSurface = Color(hex: "#004080")

    /// Muted gold / bronze - active buttons, glow, featured titles, tags.
    static let appAccent = Color(hex: "#BD9648")

    /// Lighter gold highlight.
    static let appAccentLight = Color(hex: "#D4B16B")

    /// Subtle border/separator color.
    static let appBorder = Color(hex: "#1A4D80")

    /// Primary text color.
    static let appTextPrimary = Color.white

    /// Secondary/muted text.
    static let appTextSecondary = Color(hex: "#8FB3D9")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Linear gradient used for premium buttons and highlights.
extension LinearGradient {
    static var appAccentGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.appAccent, Color.appAccentLight]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
