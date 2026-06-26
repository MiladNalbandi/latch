import SwiftUI

/// Capsule toggle that slides with a gentle spring. (design/components/core/Switch.jsx)
struct PSwitch: View {
    @Binding var isOn: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let width: CGFloat = 40
    private let height: CGFloat = 24
    private let knob: CGFloat = 18

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Palette.primary : Palette.paper200)
                .frame(width: width, height: height)
            Circle()
                .fill(Color.white)
                .frame(width: knob, height: knob)
                .elevation(Elevation.sm)
                .padding(.horizontal, 3)
        }
        .overlay(
            Capsule().strokeBorder(isOn ? .clear : Palette.lineStrong, lineWidth: 1)
        )
        .contentShape(Capsule())
        .onTapGesture {
            withAnimation(Motion.spring(reduce: reduceMotion)) { isOn.toggle() }
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

/// Soft card. (design/components/core/Card.jsx)
struct PCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(Palette.paper0)
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Palette.line, lineWidth: 1)
            )
            .elevation(Elevation.sm)
    }
}
