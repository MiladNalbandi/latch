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
import ApplicationServices

/// Pastes the picked clip into the previously-active app by simulating ⌘V.
/// Requires Accessibility permission (to post keyboard events into other apps).
enum AutoPaster {
    /// Whether the app is currently trusted for Accessibility.
    static var isTrusted: Bool { AXIsProcessTrusted() }

    /// Ask the system to prompt for Accessibility access (adds Latch to the list and shows
    /// the standard dialog). Returns the current trust state.
    @discardableResult
    static func requestAccess() -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        return AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
    }

    /// Open System Settings → Privacy & Security → Accessibility directly.
    static func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    /// Reactivate `app`, then post a synthetic ⌘V so the clip lands in it.
    /// No-op (returns false) when Accessibility isn't granted.
    @discardableResult
    static func paste(into app: NSRunningApplication?) -> Bool {
        guard isTrusted else { return false }
        app?.activate(options: [])
        // Give the target app a beat to become frontmost before delivering the keystroke.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { postCommandV() }
        return true
    }

    private static func postCommandV() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let vKey: CGKeyCode = 0x09 // 'v'
        let down = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}
