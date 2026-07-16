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

import KeyboardShortcuts
import LatchEngine
import SwiftUI

/// The frosted two-pane history panel. See specs/08-history-window and
/// design/ui_kits/app/LatchPanel.jsx.
struct HistoryPanel: View {
    @ObservedObject var vm: HistoryViewModel
    var searchFocused: FocusState<Bool>.Binding
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            filters
            Divider().overlay(Palette.line.opacity(0.6))
            panes
            footer
        }
        .frame(width: Space.panelWidth)
        .background(
            ZStack {
                VisualEffectView(material: .popover)
                Palette.paper50.opacity(Glass.tintOpacity)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.panel, style: .continuous)
                .strokeBorder(Glass.border, lineWidth: 0.5)
        )
        .overlay(alignment: .top) {
            // Inner top highlight — the glint along the top edge of the glass.
            RoundedRectangle(cornerRadius: Radius.panel, style: .continuous)
                .strokeBorder(Glass.topHighlight, lineWidth: 1)
                .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center))
                .allowsHitTesting(false)
        }
        .elevation(Elevation.panel)
        .overlay(alignment: .bottom) { toast }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            PSearchField(text: $vm.query, placeholder: "Search your clipboard…",
                         focused: searchFocused, shortcutHint: openShortcut)
            PBadge(text: "Local only", tone: .secure, dot: true)
            PIconButton(systemImage: "gearshape", label: "Settings", action: onOpenSettings)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    /// The global "open Latch" hotkey, shown as a hint in the search field.
    /// Editable in Settings → Shortcuts.
    private var openShortcut: String? {
        KeyboardShortcuts.getShortcut(for: .toggleWindow).map(String.init(describing:))
    }

    private var filters: some View {
        HStack {
            FilterBar(selection: $vm.filter)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    // MARK: Body (list + preview)

    private var panes: some View {
        HStack(spacing: 0) {
            list
                .frame(width: Space.listPaneWidth)
                .overlay(alignment: .trailing) {
                    Rectangle().fill(Palette.lineStrong.opacity(0.7)).frame(width: 1)
                }
            PreviewPane(
                item: vm.selectedItem,
                onPaste: { vm.activate() },
                onTogglePin: { vm.togglePinSelected() },
                onDelete: { vm.deleteSelected() }
            )
        }
        .frame(height: Space.bodyHeight)
    }

    private var list: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 2) {
                    if vm.results.isEmpty {
                        Text(vm.query.isEmpty ? "No clips yet." : "No clips match “\(vm.query)”.")
                            .font(.system(size: 13))
                            .foregroundColor(Palette.textFaint)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                    } else {
                        ForEach(Array(vm.results.enumerated()), id: \.element.id) { idx, item in
                            ClipRow(item: item, selected: idx == vm.selectionIndex, index: idx + 1)
                                .id(idx)
                                .onTapGesture { vm.activate(index: idx) }
                        }
                    }
                }
                .padding(6)
            }
            .onChange(of: vm.selectionIndex) { newValue in
                let anchor: UnitPoint =
                    newValue == 0 ? .top :
                    newValue == vm.results.count - 1 ? .bottom : .center
                withAnimation(.easeOut(duration: 0.12)) { proxy.scrollTo(newValue, anchor: anchor) }
            }
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 18) {
            hint(keys: ["up", "down"], label: "Navigate")
            hint(keys: ["tab"], label: "Filter")
            hint(keys: ["enter"], label: "Paste")
            hint(keys: ["cmd", "del"], label: "Delete")
            Spacer()
            hint(keys: ["esc"], label: "Close")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                VisualEffectView(material: .underWindowBackground)
                Palette.inkSurface.opacity(0.82)
            }
        )
        .foregroundColor(Palette.textOnInk.opacity(0.72))
    }

    private func hint(keys: [String], label: String) -> some View {
        HStack(spacing: 7) {
            PKbd(keys: keys, tone: .ink, size: .sm)
            Text(label).font(.system(size: 12, weight: .medium))
        }
    }

    // MARK: Toast

    @ViewBuilder private var toast: some View {
        if let toast = vm.toast {
            HStack(spacing: 8) {
                Image(systemName: "checkmark").foregroundColor(Palette.success)
                Text(toast).font(.system(size: 13, weight: .semibold))
            }
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(ZStack { VisualEffectView(material: .underWindowBackground); Palette.inkSurface.opacity(0.92) })
            .foregroundColor(.white)
            .clipShape(Capsule())
            .padding(.bottom, 58)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
