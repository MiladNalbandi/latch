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
