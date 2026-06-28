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

/// Soft, cool-ink shadows (design/tokens/shadows.css).
enum Elevation {
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let y: CGFloat
    }

    static let sm = ShadowStyle(color: Color(hex: 0x11141A, alpha: 0.06), radius: 2, y: 1)
    static let md = ShadowStyle(color: Color(hex: 0x11141A, alpha: 0.10), radius: 12, y: 4)
    static let lg = ShadowStyle(color: Color(hex: 0x11141A, alpha: 0.14), radius: 28, y: 12)
    /// Dramatic float for the Spotlight-style panel.
    static let panel = ShadowStyle(color: Color(hex: 0x11141A, alpha: 0.30), radius: 40, y: 28)
}

extension View {
    func elevation(_ s: Elevation.ShadowStyle) -> some View {
        self.shadow(color: s.color, radius: s.radius, x: 0, y: s.y)
    }
}
