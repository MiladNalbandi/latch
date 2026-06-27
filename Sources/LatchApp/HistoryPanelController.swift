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
            // The panel is reused across open/close, so onAppear only fires once — re-focus
            // the search field on every open (and on the ⌘F focus key) so typing always searches.
            .onChange(of: vm.focusTick) { _ in DispatchQueue.main.async { searchFocused = true } }
            .animation(.easeOut(duration: 0.15), value: vm.toast)
    }
}

/// A borderless panel that can still become key, so the search field accepts typing.
private final class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Hosts the frosted floating panel and owns show/hide/toggle + keyboard handling.
/// See specs/08-history-window.
final class HistoryPanelController {
    private let panel: NSPanel
    private let vm: HistoryViewModel
    private var keyMonitor: Any?
    private var toastDismiss: DispatchWorkItem?

    /// The app that was frontmost before the panel opened — the auto-paste target.
    private var previousApp: NSRunningApplication?
    /// Read at paste time so the toggle in Settings takes effect immediately.
    var isAutoPasteEnabled: () -> Bool = { false }

    init(store: HistoryStore, matcher: FuzzyMatcher, pasteboard: PasteboardWriting,
         onOpenSettings: @escaping () -> Void, onCopySound: @escaping () -> Void) {
        self.vm = HistoryViewModel(store: store, matcher: matcher, pasteboard: pasteboard)

        panel = KeyablePanel(
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
        // `.canJoinAllSpaces` and `.moveToActiveSpace` are mutually exclusive — setting both
        // raises an NSException on modern macOS. Spotlight-style panel: appear on all spaces.
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        vm.onCopySound = onCopySound
        vm.onActivate = { [weak self] in self?.dismissAndPaste() }

        let host = NSHostingView(rootView: PanelRoot(vm: vm, onOpenSettings: onOpenSettings))
        host.translatesAutoresizingMaskIntoConstraints = false
        panel.contentView = host
        panel.initialFirstResponder = host

        // Auto-dismiss toast.
        observeToast()

        // Dismiss when the panel loses focus (click outside / switch apps), like Esc.
        NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification, object: panel, queue: .main
        ) { [weak self] _ in
            guard let self, self.panel.isVisible, !self.isClosing else { return }
            self.hide()
        }
    }

    // MARK: Show / hide / toggle

    private var isClosing = false

    func toggle() { panel.isVisible ? hide() : show() }

    func show() {
        isClosing = false
        // Capture the frontmost app *before* we activate Latch — it's the paste target.
        previousApp = NSWorkspace.shared.frontmostApplication
        vm.resetForShow()
        position()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        installKeyMonitor()
        animateIn()
    }

    func hide(then completion: (() -> Void)? = nil) {
        guard !isClosing else { completion?(); return }
        isClosing = true
        removeKeyMonitor()
        animateOut { [weak self] in
            self?.panel.orderOut(nil)
            self?.isClosing = false
            completion?()
        }
    }

    /// Selection chosen: the clip is already on the pasteboard. Dismiss, then (if enabled and
    /// permitted) paste it straight into the app the user came from.
    private func dismissAndPaste() {
        let target = previousApp
        let paste = isAutoPasteEnabled() && AutoPaster.isTrusted
        hide { if paste { AutoPaster.paste(into: target) } }
    }

    // MARK: Entrance / exit animation

    private var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }

    private func animateIn() {
        guard !reduceMotion, let layer = contentLayer() else {
            panel.alphaValue = 1
            return
        }
        panel.alphaValue = 0
        layer.transform = scaleAboutTop(0.96, in: layer)
        let spring = CASpringAnimation(keyPath: "transform")
        spring.fromValue = NSValue(caTransform3D: scaleAboutTop(0.96, in: layer))
        spring.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        spring.damping = 18
        spring.stiffness = 240
        spring.mass = 1
        spring.duration = spring.settlingDuration
        layer.transform = CATransform3DIdentity
        layer.add(spring, forKey: "in")
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }
    }

    private func animateOut(_ completion: @escaping () -> Void) {
        guard !reduceMotion, let layer = contentLayer() else {
            panel.alphaValue = 1
            completion()
            return
        }
        let from = layer.transform
        let to = scaleAboutTop(0.97, in: layer)
        let scale = CABasicAnimation(keyPath: "transform")
        scale.fromValue = NSValue(caTransform3D: from)
        scale.toValue = NSValue(caTransform3D: to)
        scale.duration = Motion.fast
        scale.timingFunction = CAMediaTimingFunction(name: .easeIn)
        layer.add(scale, forKey: "out")
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = Motion.fast
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.panel.alphaValue = 1   // reset for next show
            self?.contentLayer()?.transform = CATransform3DIdentity
            completion()
        })
    }

    private func contentLayer() -> CALayer? {
        guard let view = panel.contentView else { return nil }
        view.wantsLayer = true
        return view.layer
    }

    /// Scale transform anchored at the top-center of the layer (Spotlight-style growth),
    /// computed without mutating `anchorPoint` so the panel never jumps.
    private func scaleAboutTop(_ s: CGFloat, in layer: CALayer) -> CATransform3D {
        let w = layer.bounds.width
        let h = layer.bounds.height
        var t = CATransform3DIdentity
        t = CATransform3DTranslate(t, w / 2, h, 0)
        t = CATransform3DScale(t, s, s, 1)
        t = CATransform3DTranslate(t, -w / 2, -h, 0)
        return t
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
        let shift = event.modifierFlags.contains(.shift)
        switch event.keyCode {
        case 125: vm.moveSelection(by: 1); return nil          // down
        case 126: vm.moveSelection(by: -1); return nil         // up
        case 36, 76: vm.activate(); return nil                 // return / enter
        case 53: hide(); return nil                            // escape
        case 48: vm.cycleFilter(by: shift ? -1 : 1); return nil // tab / shift-tab → filters
        case 3 where cmd: vm.focusSearch(); return nil         // cmd-F → focus search
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
