import SwiftUI

/// Sunken translucent search field with a leading magnifier. (design/components/core/Input.jsx)
struct PSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search…"
    var focused: FocusState<Bool>.Binding
    /// Optional shortcut hint shown as a trailing keycap (e.g. the global open hotkey).
    var shortcutHint: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Palette.textFaint)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Palette.textStrong)
                .focused(focused)
            if let hint = shortcutHint, !hint.isEmpty {
                PKbd(hint, tone: .default, size: .sm)
                    .opacity(0.6)
                    .help("Open Latch — change in Settings → Shortcuts")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Palette.paper0.opacity(focused.wrappedValue ? 0.9 : 0.55))
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .strokeBorder(focused.wrappedValue ? Palette.primary.opacity(0.7) : Glass.border,
                              lineWidth: focused.wrappedValue ? 1.5 : 1)
        )
        // A soft accent glow when focused — reads as "field is active/ready to type",
        // distinct from a selected clip (which uses an accent tint-fill + leading bar).
        .shadow(color: focused.wrappedValue ? Palette.primary.opacity(0.25) : .clear,
                radius: 4, y: 0)
    }
}
