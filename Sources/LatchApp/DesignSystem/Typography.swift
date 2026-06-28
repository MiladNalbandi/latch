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

import SwiftUI

/// Typography mapped to system fonts (SF Pro / SF Mono / SF Pro Rounded for display).
/// Sizes from design/tokens/typography.css.
enum Typo {
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Display headings — SF Pro Rounded bold echoes Bricolage's friendly feel.
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    // Common roles
    static let body = ui(15)
    static let bodyStrong = ui(15, .semibold)
    static let small = ui(13)
    static let caption = ui(12)
    static let eyebrow = ui(11, .bold)
}

extension View {
    /// Uppercase tracked eyebrow/overline label, usually green.
    func eyebrowStyle(_ color: Color = Palette.primary) -> some View {
        self.font(Typo.eyebrow)
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}
