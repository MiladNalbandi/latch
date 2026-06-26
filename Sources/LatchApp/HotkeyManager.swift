import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    /// Open/toggle the history panel. Default ⌘⇧V.
    static let toggleWindow = Self("toggleWindow", default: .init(.v, modifiers: [.command, .shift]))
    /// Copy the most-recent clip back to the clipboard without opening the panel. Default ⌘⌥V.
    static let quickPaste = Self("quickPaste", default: .init(.v, modifiers: [.command, .option]))
}

/// Registers the two global shortcuts. See specs/07-global-hotkey.
final class HotkeyManager {
    init(onToggle: @escaping () -> Void, onQuickPaste: @escaping () -> Void) {
        KeyboardShortcuts.onKeyUp(for: .toggleWindow) { onToggle() }
        KeyboardShortcuts.onKeyUp(for: .quickPaste) { onQuickPaste() }
    }
}
