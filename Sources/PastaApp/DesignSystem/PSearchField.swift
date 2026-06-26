import SwiftUI

/// Sunken translucent search field with a leading magnifier. (design/components/core/Input.jsx)
struct PSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search…"
    var focused: FocusState<Bool>.Binding

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
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.white.opacity(focused.wrappedValue ? 0.82 : 0.5))
        .clipShape(RoundedRectangle(cornerRadius: Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.control, style: .continuous)
                .strokeBorder(focused.wrappedValue ? Palette.primary : Color.white.opacity(0.7),
                              lineWidth: focused.wrappedValue ? 2 : 1)
        )
    }
}
