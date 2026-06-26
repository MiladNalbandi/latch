import SwiftUI
import AppKit

/// Frosted-glass surface via `NSVisualEffectView`, used for the floating panel and footer.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context _: Context) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
    }
}

/// Motion tokens (design/tokens/motion.css), reduce-motion aware.
enum Motion {
    static let fast: Double = 0.14
    static let base: Double = 0.20

    static func standard(reduce: Bool) -> Animation {
        reduce ? .easeOut(duration: fast) : .easeOut(duration: base)
    }

    /// Gentle spring with a small overshoot (never cartoon bounce).
    static func spring(reduce: Bool) -> Animation {
        reduce ? .easeOut(duration: fast) : .spring(response: 0.32, dampingFraction: 0.72)
    }
}
