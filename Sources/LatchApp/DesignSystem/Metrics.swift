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
