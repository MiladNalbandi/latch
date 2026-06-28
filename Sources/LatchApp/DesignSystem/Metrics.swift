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

/// Radii (design/tokens/radius.css).
enum Radius {
    static let sm: CGFloat = 6
    static let control: CGFloat = 10
    static let card: CGFloat = 14
    static let panel: CGFloat = 16
    static let keycap: CGFloat = 7
    static let full: CGFloat = 999
}

/// Spacing (4px grid) and panel sizing (design/tokens/spacing.css + .lp CSS).
enum Space {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let xxl: CGFloat = 20
    static let xxxl: CGFloat = 24

    // Panel dimensions (from the zip's .lp CSS / Desktop.jsx)
    static let panelWidth: CGFloat = 720
    static let listPaneWidth: CGFloat = 322
    static let bodyHeight: CGFloat = 366
}
