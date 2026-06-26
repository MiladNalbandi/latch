# 08 — History Window — Tasks

- [ ] **T-08.1** Implement `HistoryViewModel` (query → results via `FuzzyMatcher`,
  selection, copy-back), subscribed to `store.$items`. _(08-AC-3, 08-AC-4)_
- [ ] **T-08.2** Implement `moveSelection(by:)` with end-clamping. _(08-AC-5)_
- [ ] **T-08.3** Implement `copySelected()` writing plain text + RTF via
  `PasteboardWriting`. _(08-AC-6, 08-AC-11)_
- [ ] **T-08.4** Reset selection to top whenever the query changes. _(08-AC-9)_
- [ ] **T-08.5** Implement `HistoryWindowController` with a floating non-activating
  `NSPanel` hosting the SwiftUI view; `show()`/`hide()`/`toggle()`. _(08-AC-1, 08-AC-10)_
- [ ] **T-08.6** Focus the search field on show; activate the app so the panel can become
  key. _(08-AC-2)_
- [ ] **T-08.7** Hide on resign-key / deactivate. _(08-AC-8)_
- [ ] **T-08.8** Implement `HistoryListView` (search field + list + row, double-click to
  commit). _(08-AC-3, 08-AC-4)_
- [ ] **T-08.9** Add keyboard handling (↑/↓/Return/Esc) via a local key monitor or
  responder bridge compatible with macOS 13. _(08-AC-5, 08-AC-6, 08-AC-7)_
- [ ] **T-08.10** Wire `onCommit` → copy + hide and `onCancel` → hide. _(08-AC-6,
  08-AC-7)_

## Verification (manual, on a Mac)

- [ ] Hotkey/menu opens a floating window with the search field focused. _(08-AC-1,
  08-AC-2)_
- [ ] Typing filters the list live and resets selection to the top. _(08-AC-3, 08-AC-9)_
- [ ] ↑/↓ move the selection and clamp at the ends. _(08-AC-5)_
- [ ] Enter copies the selected item back (paste into a text editor to confirm; RTF
  styling preserved when present) and the window hides. _(08-AC-6)_
- [ ] Re-copying an existing item moves it to the top without duplicating. _(08-AC-11)_
- [ ] Esc hides without changing the clipboard. _(08-AC-7)_
- [ ] Clicking another app hides the window. _(08-AC-8)_
