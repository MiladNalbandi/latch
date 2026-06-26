import SwiftUI

/// Soft, cool-ink shadows (design/tokens/shadows.css).
enum Elevation {
    struct ShadowStyle { let color: Color; let radius: CGFloat; let y: CGFloat }

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
