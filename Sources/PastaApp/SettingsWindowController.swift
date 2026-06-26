import AppKit
import SwiftUI
import PastaEngine

/// Hosts the settings view in a single titled window. See specs/09-preferences.
final class SettingsWindowController {
    private var window: NSWindow?
    private let prefs: Preferences
    private let loginItem: LoginItemManager
    private let onClearAll: () -> Void

    init(prefs: Preferences, loginItem: LoginItemManager, onClearAll: @escaping () -> Void) {
        self.prefs = prefs
        self.loginItem = loginItem
        self.onClearAll = onClearAll
    }

    func show() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }
        let view = SettingsView(prefs: prefs, loginItem: loginItem, onClearAll: onClearAll)
        let hosting = NSHostingController(rootView: view)
        let w = NSWindow(contentViewController: hosting)
        w.title = "pasta Settings"
        w.styleMask = [.titled, .closable, .miniaturizable]
        w.isReleasedWhenClosed = false
        w.center()
        window = w
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }
}
