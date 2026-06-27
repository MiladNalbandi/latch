import SwiftUI
import LatchEngine

/// Relative timestamp ("just now", "4m ago", "Yesterday"). Shared by row + preview.
enum RelativeTime {
    static func string(for date: Date, now: Date = Date()) -> String {
        let s = now.timeIntervalSince(date)
        if s < 45 { return "just now" }
        if s < 3600 { return "\(Int(s / 60))m ago" }
        if s < 86_400 { return "\(Int(s / 3600))h ago" }
        if s < 172_800 { return "Yesterday" }
        return "\(Int(s / 86_400))d ago"
    }
}

/// The signature history row. (design/components/clipboard/ClipItem.jsx)
struct ClipRow: View {
    let item: ClipItem
    var selected: Bool = false
    var index: Int? = nil   // 1-9 quick-pick

    @State private var hovering = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            typeTile
            VStack(alignment: .leading, spacing: 3) {
                Text(item.preview.isEmpty ? item.type.label : item.preview)
                    .font(isMono ? Typo.mono(13) : .system(size: 14, weight: .medium))
                    .foregroundColor(Palette.textStrong)
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack(spacing: 7) {
                    if let src = item.source {
                        Text(src).font(.system(size: 12, weight: .semibold)).foregroundColor(Palette.textBody)
                        Circle().fill(Palette.ink200).frame(width: 3, height: 3)
                    }
                    Text(RelativeTime.string(for: item.createdAt))
                        .font(.system(size: 12)).foregroundColor(Palette.textMuted)
                }
            }
            Spacer(minLength: 0)
            if item.pinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Palette.accent)
            }
            if selected, let idx = index, idx <= 9 {
                PKbd("\(idx)", tone: .default, size: .sm)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .strokeBorder(selected ? Palette.primaryTint : .clear, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            // Accent leading bar — guarantees a visible selected state for any accent
            // (incl. low-saturation graphite, where the tint fill alone is faint).
            Capsule()
                .fill(Palette.primary)
                .frame(width: 3, height: 22)
                .padding(.leading, 3)
                .opacity(selected ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onHover { h in withAnimation(Motion.standard(reduce: reduceMotion)) { hovering = h } }
    }

    private var rowBackground: Color {
        if selected { return Palette.primaryTintSoft }
        return hovering ? Palette.paper100 : Color.clear
    }

    private var isMono: Bool { item.type == .code || item.type == .link }

    @ViewBuilder private var typeTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).fill(tileBg)
            if item.type == .color, let color = swatchColor {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous).fill(color)
            } else {
                Image(systemName: item.type.symbolName)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(tileFg)
            }
        }
        .frame(width: 38, height: 38)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                .strokeBorder(item.type == .color ? Palette.line : .clear, lineWidth: 1)
        )
    }

    private var tileBg: Color {
        switch item.type {
        case .link: return Palette.secureTint
        case .code: return Palette.inkSurface
        default: return Palette.paper100
        }
    }
    private var tileFg: Color {
        switch item.type {
        case .link: return Palette.secure
        // The code tile is a dark surface in both modes, so its glyph stays light.
        case .code: return Palette.textOnInk
        default: return Palette.textMuted
        }
    }
    private var swatchColor: Color? {
        guard item.type == .color, let hex = item.plainText else { return nil }
        return Color(hexString: hex)
    }
}

extension Color {
    /// Parse "#RRGGBB" / "RRGGBB" / "#RGB" into a Color (nil-safe via fallback).
    init?(hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        guard s.count == 6 || s.count == 8, let v = UInt32(s.prefix(6), radix: 16) else { return nil }
        self.init(hex: v)
    }
}
