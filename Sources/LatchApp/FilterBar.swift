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
            .foregroundColor(on ? Palette.primary : Palette.textMuted)
            .padding(.horizontal, 11)
            .padding(.vertical, 5)
            .background(on ? Palette.paper0.opacity(0.92) : Color.clear)
            .clipShape(Capsule())
            .elevation(on ? Elevation.sm : Elevation.ShadowStyle(color: .clear, radius: 0, y: 0))
            .contentShape(Capsule())
            .onTapGesture { selection = f }
    }
}
