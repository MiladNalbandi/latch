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

/// Frosted-glass surface via `NSVisualEffectView`, used for the floating panel and footer.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context _: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        // The panel is a non-activating panel, so keep the vibrancy vivid even when not key.
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context _: Context) {
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
    }
}

/// Glass surface tokens (design/tokens/materials.css), light/dark aware.
enum Glass {
    /// Tint overlay opacity over the frosted material — lower reads glassier, higher aids
    /// text legibility. 0.48 keeps the glass look while making copied text crisp.
    static let tintOpacity: Double = 0.48
    /// Edge stroke that sells the "pane of glass".
    static let border = Color(light: .white.opacity(0.55), dark: .white.opacity(0.10))
    /// Subtle inner top highlight.
    static let topHighlight = Color(light: .white.opacity(0.65), dark: .white.opacity(0.08))
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

    /// Panel entrance/exit spring (slightly snappier than `spring`).
    static func panel(reduce: Bool) -> Animation {
        reduce ? .easeOut(duration: fast) : .spring(response: 0.30, dampingFraction: 0.78)
    }
}
