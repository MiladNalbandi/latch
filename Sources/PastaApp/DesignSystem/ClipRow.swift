import SwiftUI
import PastaEngine

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
                    .foregroundColor(Palette.amber500)
            }
            if selected, let idx = index, idx <= 9 {
                PKbd("\(idx)", tone: .default, size: .sm)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(selected ? Palette.primaryTintSoft : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .strokeBorder(selected ? Palette.primaryTint : .clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
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
        case .link: return Palette.blue600
        case .code: return Palette.green300
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
