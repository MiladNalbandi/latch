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

import AppKit
import SwiftUI
import LatchEngine

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
        w.title = "Latch Settings"
        w.styleMask = [.titled, .closable, .miniaturizable]
        w.isReleasedWhenClosed = false
        w.center()
        window = w
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
    }
}
