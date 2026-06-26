import SwiftUI

/// The filter-chip row (All / Pinned / Links / Text / Code / Colors). See specs/08.
struct FilterBar: View {
    @Binding var selection: HistoryViewModel.ClipFilter

    var body: some View {
        HStack(spacing: 6) {
            ForEach(HistoryViewModel.ClipFilter.allCases) { f in
                chip(f)
            }
        }
    }

    private func chip(_ f: HistoryViewModel.ClipFilter) -> some View {
        let on = selection == f
        return Text(f.label)
            .font(.system(size: 12.5, weight: .semibold))
            .foregroundColor(on ? Palette.primaryPress : Palette.textMuted)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(on ? Color.white.opacity(0.92) : Color.clear)
            .clipShape(Capsule())
            .elevation(on ? Elevation.sm : Elevation.ShadowStyle(color: .clear, radius: 0, y: 0))
            .contentShape(Capsule())
            .onTapGesture { selection = f }
    }
}
