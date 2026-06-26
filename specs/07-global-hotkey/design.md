# 07 — Global Hotkey — Design

## Files

```
Sources/LatchApp/HotkeyManager.swift
```

Depends on the `KeyboardShortcuts` SPM package (declared in `project.yml`, feature 00).

## Shortcut name

```swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleWindow = Self("toggleWindow",
                                   default: .init(.v, modifiers: [.command, .shift]))
}
```

- The `default:` initializer sets ⌘⇧V only if the user hasn't chosen one (07-AC-5).
- The library stores the user's choice in `UserDefaults` automatically (07-AC-4).

## HotkeyManager

```swift
final class HotkeyManager {
    init(onToggle: @escaping () -> Void) {
        KeyboardShortcuts.onKeyUp(for: .toggleWindow) {     // 07-AC-6
            onToggle()                                      // 07-AC-2 / 07-AC-3
        }
    }
}
```

- The manager registers exactly one handler at construction (called from `AppDelegate`,
  feature 06).
- `onToggle` is wired to `HistoryWindowController.toggle()` (feature 08), which decides
  show-vs-hide based on current window visibility — satisfying both 07-AC-2 and 07-AC-3 in
  one place.

## Permissions

Global shortcuts via KeyboardShortcuts use Carbon `RegisterEventHotKey` under the hood and
generally do **not** require Accessibility permission for plain hotkeys. If a future
feature needs to synthesize key events (e.g. auto-paste), that would require Accessibility
— out of scope for MVP (we only copy to the pasteboard).

## Edge cases

- User clears the shortcut in Preferences → no global toggle; window still reachable via
  the status menu (feature 06).
- Shortcut conflicts with another app: the recorder in feature 09 warns; resolution is the
  user's choice.
- Handler registered once; toggling logic (visibility check) lives in the window
  controller to keep a single source of truth.

## Testing

This feature is UI/system-integration and not unit-tested in `LatchEngineTests`. Verified
manually (see tasks). The toggle decision logic is exercised through feature 08.
