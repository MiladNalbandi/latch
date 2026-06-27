import AppKit
import LatchEngine
import SwiftUI

/// Hosts the first-run welcome screen in a single titled window.
final class WelcomeWindowController {
    private var window: NSWindow?
    private let onOpenSettings: () -> Void

    init(onOpenSettings: @escaping () -> Void) {
        self.onOpenSettings = onOpenSettings
    }

    func show() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let view = WelcomeView(
            onStart: { [weak self] in self?.window?.close() },
            onOpenSettings: { [weak self] in self?.window?.close(); self?.onOpenSettings() }
        )
        let hosting = NSHostingController(rootView: view)
        let w = NSWindow(contentViewController: hosting)
        w.title = "Welcome to Latch"
        w.styleMask = [.titled, .closable]
        w.isReleasedWhenClosed = false
        w.center()
        window = w
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }
}
