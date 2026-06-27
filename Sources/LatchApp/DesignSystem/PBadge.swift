import SwiftUI

/// Small pill label. (design/components/core/Badge.jsx)
struct PBadge: View {
    enum Tone { case neutral, primary, secure, success, danger }

    let text: String
    var tone: Tone = .neutral
    var dot: Bool = false
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            if dot {
                Circle().fill(fg).frame(width: 6, height: 6)
            }
            if let s = systemImage {
                Image(systemName: s).font(.system(size: 10, weight: .semibold))
            }
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(fg)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(bg)
        .clipShape(Capsule())
    }

    private var fg: Color {
        switch tone {
        case .neutral: return Palette.textMuted
        case .primary: return Palette.primaryPress
        case .secure: return Palette.secure
        case .success: return Palette.success
        case .danger: return Palette.dangerStrong
        }
    }
    private var bg: Color {
        switch tone {
        case .neutral: return Palette.paper100
        case .primary: return Palette.primaryTint
        case .secure: return Palette.secureTint
        case .success: return Palette.successTint
        case .danger: return Palette.dangerTint
        }
    }
}
