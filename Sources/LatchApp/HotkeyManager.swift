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
