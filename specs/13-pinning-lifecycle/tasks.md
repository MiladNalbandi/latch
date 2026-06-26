# 13 — Pinning & Lifecycle — Tasks

- [ ] **T-13.1** Add `pinned` to `ClipItem`; `HistoryStore.togglePin(id:)` + pinned-first
  `sortItems()`. _(13-AC-1, 13-AC-2)_
- [ ] **T-13.2** Make `enforceCap()` evict only unpinned. _(13-AC-3)_
- [ ] **T-13.3** Add `isPaused` to `ClipboardMonitor`; skip capture + advance
  `lastChangeCount` while paused. _(13-AC-5, 13-AC-6)_
- [ ] **T-13.4** Implement `LockMonitor` on `com.apple.screenIsLocked`. _(13-AC-4)_
- [ ] **T-13.5** Wire incognito (Preferences → monitor.isPaused + menu-bar indicator) and
  clear-on-lock (Preferences → LockMonitor → store.clear) in `AppDelegate`. _(13-AC-4,
  13-AC-5)_

## Tests (LatchEngineTests / HistoryStoreTests + ClipboardMonitorTests)

- [ ] **TT-13.a** Pin an old item; add many new → pinned stays at top and is not evicted.
  _(13-AC-2, 13-AC-3)_
- [ ] **TT-13.b** `togglePin` flips and re-sorts; persists via fake persistence. _(13-AC-1)_
- [ ] **TT-13.c** Monitor with `isPaused = true` → no `onCapture`, and `lastChangeCount`
  tracks pasteboard so resume doesn't back-fill. _(13-AC-5, 13-AC-6)_

## Verification (manual, on a Mac)

- [ ] Pin a clip → it sticks to the top; fill history past the cap → pinned survives.
- [ ] Enable incognito → copying does nothing; menu bar shows paused; disable → resumes.
- [ ] Enable clear-on-lock → lock the Mac (⌃⌘Q) → history is empty on unlock.
