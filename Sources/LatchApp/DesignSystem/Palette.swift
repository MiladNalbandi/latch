// Latch — the friendly, private clipboard for macOS.
// Copyright (C) 2026 Milad Nalbandi
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import AppKit
import SwiftUI

extension Color {
    /// 0xRRGGBB convenience.
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    /// Resolves per the drawing view's effective appearance (light/dark), live — so a single
    /// token adapts to system dark mode without threading `colorScheme` through every view.
    init(light: Color, dark: Color) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return NSColor(isDark ? dark : light)
        })
    }

    /// Light/dark pair from two `0xRRGGBB` hex values.
    init(lightHex: UInt32, darkHex: UInt32) {
        self.init(light: Color(hex: lightHex), dark: Color(hex: darkHex))
    }
}

/// Latch color tokens. Surfaces/text adapt to system light/dark; every accent follows the
/// macOS system accent (`Color.accentColor` / `NSColor.controlAccentColor`).
enum Palette {
    // MARK: Surfaces (warm paper in light, cool ink in dark)

    static let paper0 = Color(lightHex: 0xFFFFFF, darkHex: 0x22272F)
    static let paper50 = Color(lightHex: 0xFBFAF6, darkHex: 0x181C23)
    static let paper100 = Color(lightHex: 0xF4F2EC, darkHex: 0x20252E)
    static let paper200 = Color(lightHex: 0xEBE8DF, darkHex: 0x2B313B)
    static let line = Color(lightHex: 0xE4E1D8, darkHex: 0x333A45)
    static let lineStrong = Color(lightHex: 0xD4D0C4, darkHex: 0x454D59)

    // MARK: Text

    static let textStrong = Color(lightHex: 0x11141A, darkHex: 0xEEF0F2)
    static let textBody = Color(lightHex: 0x2B313B, darkHex: 0xD6DAE0)
    static let textMuted = Color(lightHex: 0x5A626E, darkHex: 0xAEB6C0)
    static let textFaint = Color(lightHex: 0x7A828D, darkHex: 0x8B939E)
    static let ink800 = Color(lightHex: 0x1B1F27, darkHex: 0xE2E5E9) // keycap default fg
    static let ink200 = Color(lightHex: 0xC3C8CF, darkHex: 0x4A515C) // tiny separators

    // MARK: Dark "ink" band (footer, keycaps, toast)
    // Intentionally a dark surface with light text in BOTH appearances — it's a brand
    // element and must not invert in dark mode. Deepened slightly in dark so it still
    // separates from the (now dark) panel body.

    static let inkSurface = Color(lightHex: 0x181C23, darkHex: 0x0F1318)
    static let inkSurface2 = Color(lightHex: 0x20252E, darkHex: 0x161A20)
    static let textOnInk = Color(hex: 0xEEF0F2)

    // MARK: Accent — follows the macOS system accent

    static let primary = Color.accentColor
    static let primaryTint = Color.accentColor.opacity(0.16)
    static let primaryTintSoft = Color.accentColor.opacity(0.08)

    /// Darker accent for hover/press fills (e.g. the "go" keycap edge).
    static var primaryHover: Color { accentBlended(0.15) }
    static var primaryPress: Color { accentBlended(0.28) }

    /// Legible foreground (black/white) on top of the accent fill — flips for light accents
    /// like yellow and dark ones like graphite.
    static var onPrimary: Color {
        Color(nsColor: NSColor(name: nil) { _ in
            let c = NSColor.controlAccentColor.usingColorSpace(.sRGB) ?? .white
            let lum = 0.299 * c.redComponent + 0.587 * c.greenComponent + 0.114 * c.blueComponent
            return lum > 0.6 ? .black : .white
        })
    }

    // Every semantic accent follows the system accent (per design decision).
    static let secure = Color.accentColor
    static let secureTint = Color.accentColor.opacity(0.14)
    static let danger = Color.accentColor
    static let dangerStrong = Color.accentColor
    static let dangerTint = Color.accentColor.opacity(0.14)
    static let accent = Color.accentColor
    static let success = Color.accentColor
    static let successTint = Color.accentColor.opacity(0.14)

    // MARK: Helpers

    /// The system accent blended toward black by `fraction`, resolved live.
    private static func accentBlended(_ fraction: CGFloat) -> Color {
        Color(nsColor: NSColor(name: nil) { _ in
            NSColor.controlAccentColor.blended(withFraction: fraction, of: .black) ?? .controlAccentColor
        })
    }
}
