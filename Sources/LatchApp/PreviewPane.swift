import SwiftUI
import LatchEngine

/// The right-hand preview + actions for the selected clip. See specs/08-history-window.
struct PreviewPane: View {
    let item: ClipItem?
    var onPaste: () -> Void
    var onTogglePin: () -> Void
    var onDelete: () -> Void

    var body: some View {
        if let item {
            content(item)
        } else {
            empty
        }
    }

    private var empty: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.on.clipboard").font(.system(size: 30)).foregroundColor(Palette.textFaint)
            Text("Nothing selected").font(.system(size: 13)).foregroundColor(Palette.textFaint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func content(_ item: ClipItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Head: type badge + pinned + time
            HStack(spacing: 8) {
                PBadge(text: item.type.label, tone: .neutral, systemImage: item.type.symbolName)
                if item.pinned { PBadge(text: "Pinned", tone: .primary, systemImage: "pin.fill") }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "clock").font(.system(size: 12))
                    Text(RelativeTime.string(for: item.createdAt)).font(Typo.mono(12))
                }
                .foregroundColor(Palette.textMuted)
            }

            // Body: color swatch or content box
            if item.type == .color, let hex = item.plainText, let color = Color(hexString: hex) {
                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                        .fill(color)
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .overlay(RoundedRectangle(cornerRadius: Radius.control).strokeBorder(Color(light: .black.opacity(0.06), dark: .white.opacity(0.08))))
                    Text(hex.uppercased()).font(Typo.mono(18, .semibold)).foregroundColor(Palette.textStrong)
                }
            } else {
                ScrollView {
                    Text(previewBody(item))
                        .font(isMono(item) ? Typo.mono(14) : .system(size: 17, weight: .medium))
                        .foregroundColor(Palette.textStrong)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .padding(14)
                .background(Palette.paper0.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: Radius.control).strokeBorder(Palette.line, lineWidth: 1))
                .frame(maxHeight: .infinity)
            }

            // Meta line
            HStack(spacing: 9) {
                if let src = item.source {
                    HStack(spacing: 4) { Text("From"); Text(src).fontWeight(.semibold).foregroundColor(Palette.textBody) }
                    dot
                }
                Text("\(item.characterCount) chars")
                dot
                HStack(spacing: 5) {
                    Image(systemName: "lock.shield").font(.system(size: 12))
                    Text("Local only").fontWeight(.semibold)
                }
                .foregroundColor(Palette.secure)
            }
            .font(.system(size: 12.5))
            .foregroundColor(Palette.textMuted)

            // Actions
            HStack(spacing: 10) {
                PButton(title: "Paste", variant: .primary, systemImage: "checkmark", action: onPaste)
                PButton(title: item.pinned ? "Unpin" : "Pin", variant: .secondary, systemImage: "pin", action: onTogglePin)
                Spacer()
                PIconButton(systemImage: "trash", label: "Delete", action: onDelete)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.paper0.opacity(0.6))
    }

    private var dot: some View { Circle().fill(Palette.ink200).frame(width: 3, height: 3) }
    private func isMono(_ item: ClipItem) -> Bool { item.type == .code || item.type == .link }
    private func previewBody(_ item: ClipItem) -> String {
        item.plainText ?? item.preview
    }
}
