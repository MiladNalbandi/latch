# 07 — Global Hotkey — Tasks

- [ ] **T-07.1** Add `KeyboardShortcuts.Name.toggleWindow` with a default of ⌘⇧V.
  _(07-AC-1, 07-AC-5)_
- [ ] **T-07.2** Implement `HotkeyManager` registering a single `onKeyUp` handler that
  calls the injected `onToggle`. _(07-AC-6)_
- [ ] **T-07.3** Wire `HotkeyManager(onToggle:)` to `HistoryWindowController.toggle()` in
  `AppDelegate`. _(07-AC-2, 07-AC-3)_

## Verification (manual, on a Mac)

- [ ] Press ⌘⇧V from another app → the history window appears and is focused. _(07-AC-2)_
- [ ] Press ⌘⇧V again → the window hides. _(07-AC-3)_
- [ ] Change the shortcut in Preferences (feature 09), relaunch the app → the new shortcut
  still works (persistence). _(07-AC-4)_
- [ ] Clear the shortcut → status-menu "Show Latch" still opens the window. _(graceful
  degradation)_
