import SwiftUI
import PastaEngine

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
                VisualEffectView(material: .hudWindow)
                Palette.paper50.opacity(0.6)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.panel, style: .continuous).strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5))
        .elevation(Elevation.panel)
        .overlay(alignment: .bottom) { toast }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 10) {
            PSearchField(text: $vm.query, placeholder: "Search your clipboard…", focused: searchFocused)
            PBadge(text: "Local only", tone: .secure, dot: true)
            PIconButton(systemImage: "gearshape", label: "Settings", action: onOpenSettings)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
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
                    Rectangle().fill(Palette.line.opacity(0.6)).frame(width: 0.5)
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
                withAnimation(.easeOut(duration: 0.12)) { proxy.scrollTo(newValue, anchor: .center) }
            }
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 18) {
            hint(keys: ["up", "down"], label: "Navigate")
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
        .foregroundColor(Color.white.opacity(0.72))
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
                Image(systemName: "checkmark").foregroundColor(Palette.green300)
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
