import SwiftUI

/// Button matching design/components/core/Button.jsx. Press scales to 0.97.
struct PButton: View {
    enum Variant { case primary, secondary, ghost, danger, secure }
    enum Size { case sm, md, lg }

    let title: String
    var variant: Variant = .primary
    var size: Size = .md
    var systemImage: String? = nil
    let action: () -> Void

    @State private var pressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let s = systemImage {
                    Image(systemName: s).font(.system(size: iconSize, weight: .semibold))
                }
                Text(title).font(.system(size: fontSize, weight: .semibold))
            }
            .foregroundColor(fg)
            .padding(.horizontal, padX)
            .padding(.vertical, padY)
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
            .scaleEffect(pressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { p in
            withAnimation(Motion.standard(reduce: reduceMotion)) { pressed = p }
        }, perform: {})
    }

    private var fg: Color {
        switch variant {
        case .primary: return Palette.onPrimary
        case .secondary: return Palette.textStrong
        case .ghost: return Palette.textBody
        case .danger: return .white
        case .secure: return .white
        }
    }
    private var bg: Color {
        switch variant {
        case .primary: return Palette.primary
        case .secondary: return Palette.paper0
        case .ghost: return .clear
        case .danger: return Palette.danger
        case .secure: return Palette.secure
        }
    }
    private var border: Color {
        variant == .secondary ? Palette.lineStrong : .clear
    }
    private var fontSize: CGFloat { size == .sm ? 13 : (size == .lg ? 16 : 15) }
    private var iconSize: CGFloat { fontSize - 1 }
    private var padX: CGFloat { size == .sm ? 11 : (size == .lg ? 22 : 16) }
    private var padY: CGFloat { size == .sm ? 6 : (size == .lg ? 12 : 9) }
}

/// Ghost-hover icon button. (design/components/core/IconButton.jsx)
struct PIconButton: View {
    let systemImage: String
    var label: String = ""
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Palette.textBody)
                .frame(width: 30, height: 30)
                .background(hovering ? Palette.paper100 : .clear)
                .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(label)
        .onHover { hovering = $0 }
    }
}
