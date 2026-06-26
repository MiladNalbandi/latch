import AppKit
import SwiftUI
import Combine
import LatchEngine

/// SwiftUI root that owns search focus and forwards it to the panel.
private struct PanelRoot: View {
    @ObservedObject var vm: HistoryViewModel
    @FocusState private var searchFocused: Bool
    var onOpenSettings: () -> Void

    var body: some View {
        HistoryPanel(vm: vm, searchFocused: $searchFocused, onOpenSettings: onOpenSettings)
            .onAppear { DispatchQueue.main.async { searchFocused = true } }
            .animation(.easeOut(duration: 0.15), value: vm.toast)
    }
}

/// Hosts the frosted floating panel and owns show/hide/toggle + keyboard handling.
/// See specs/08-history-window.
final class HistoryPanelController {
    private let panel: NSPanel
    private let vm: HistoryViewModel
    private var keyMonitor: Any?
    private var toastDismiss: DispatchWorkItem?

    init(store: HistoryStore, matcher: FuzzyMatcher, pasteboard: PasteboardWriting,
         onOpenSettings: @escaping () -> Void, onCopySound: @escaping () -> Void) {
        self.vm = HistoryViewModel(store: store, matcher: matcher, pasteboard: pasteboard)

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: Space.panelWidth, height: 520),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = true
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isOpaque = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .moveToActiveSpace]

        vm.onCopySound = onCopySound
        vm.onActivate = { [weak self] in self?.hide() }

        let host = NSHostingView(rootView: PanelRoot(vm: vm, onOpenSettings: onOpenSettings))
        host.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = host

        // Auto-dismiss toast.
        observeToast()
    }

    // MARK: Show / hide / toggle

    func toggle() { panel.isVisible ? hide() : show() }

    func show() {
        vm.resetForShow()
        position()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        installKeyMonitor()
    }

    func hide() {
        removeKeyMonitor()
        panel.orderOut(nil)
    }

    private func position() {
        panel.contentView?.layoutSubtreeIfNeeded()
        guard let screen = NSScreen.main else { return }
        let size = panel.contentView?.fittingSize ?? NSSize(width: Space.panelWidth, height: 520)
        panel.setContentSize(size)
        let vf = screen.visibleFrame
        let x = vf.midX - size.width / 2
        let y = vf.maxY - size.height - 80   // near the top, Spotlight-style
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: Keyboard

    private func installKeyMonitor() {
        removeKeyMonitor()
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return self.handle(event)
        }
    }

    private func removeKeyMonitor() {
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
    }

    private func handle(_ event: NSEvent) -> NSEvent? {
        let cmd = event.modifierFlags.contains(.command)
        switch event.keyCode {
        case 125: vm.moveSelection(by: 1); return nil          // down
        case 126: vm.moveSelection(by: -1); return nil         // up
        case 36, 76: vm.activate(); return nil                 // return / enter
        case 53: hide(); return nil                            // escape
        case 51 where cmd: vm.deleteSelected(); return nil     // cmd-delete
        default:
            // Cmd+1…Cmd+9 → quick-pick (avoids clashing with typing digits in search).
            if cmd, let chars = event.charactersIgnoringModifiers,
               let n = Int(chars), (1...9).contains(n) {
                vm.activate(index: n - 1)
                return nil
            }
            return event
        }
    }

    // MARK: Toast lifecycle

    private func observeToast() {
        // The view sets vm.toast; clear it after a beat.
        vm.$toast
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.toastDismiss?.cancel()
                let work = DispatchWorkItem { [weak self] in self?.vm.toast = nil }
                self?.toastDismiss = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: work)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
}
