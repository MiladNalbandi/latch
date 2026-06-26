# 06 — Menu Bar — Tasks

- [ ] **T-06.1** Implement `@main AppDelegate` and set activation policy `.accessory`.
  _(06-AC-6)_
- [ ] **T-06.2** In `applicationDidFinishLaunching`, construct and wire `Preferences`,
  `SystemPasteboard`, `JSONHistoryPersistence`, `HistoryStore` (load), `ClipboardMonitor`
  (`onCapture` → `store.add`, start). _(06-AC-7)_
- [ ] **T-06.3** Implement `StatusItemController` with an SF Symbol icon and a menu
  (Show / Preferences… / Quit). _(06-AC-1, 06-AC-2)_
- [ ] **T-06.4** Wire menu actions: Show → window toggle, Preferences → prefs window,
  Quit → terminate. _(06-AC-3, 06-AC-4, 06-AC-5)_
- [ ] **T-06.5** Implement `applicationWillTerminate` → `persistence.flush()`.
  _(06-AC-5, 06-AC-8)_

## Verification

- `make run` on a Mac: a clipboard icon appears in the menu bar, no Dock icon.
- The menu shows Show / Preferences… / Quit; each action works (Show toggles the window
  once feature 08 exists; Quit exits and writes history).
- Manual: copy something, Quit via the menu, relaunch → item persisted (confirms flush).

> Note: Show/Preferences depend on features 08/09; during incremental build they may be
> stubbed to a no-op or simple window until those features land.
