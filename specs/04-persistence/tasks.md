# 04 — Persistence — Tasks

- [ ] **T-04.1** Define `HistoryPersisting` protocol (`load`, `save`, optional `flush`).
  _(04-AC-7)_
- [ ] **T-04.2** Implement `JSONHistoryPersistence.defaultURL` under Application Support.
  _(04-AC-1)_
- [ ] **T-04.3** Implement `load()` with missing-file and corrupt-file fallbacks to `[]`.
  _(04-AC-3, 04-AC-4, 04-AC-5)_
- [ ] **T-04.4** Implement `performWrite(_:)` with directory creation and atomic write.
  _(04-AC-2, 04-AC-6)_
- [ ] **T-04.5** Implement debounced `save(_:)` and `flush()`. _(04-AC-8)_
- [ ] **T-04.6** Implement `FakePersistence` test double. _(supports 04-AC-7)_
- [ ] **T-04.7** Wire `flush()` into the app's `applicationWillTerminate`
  (cross-references feature 06 wiring). _(04-AC-8)_

## Tests (LatchEngineTests / PersistenceTests, using a temp-dir fileURL)

- [ ] **TT-04.a** `save` then `load` round-trips an array of `ClipItem`s equal to the
  input. _(04-AC-1, 04-AC-2, 04-AC-3)_
- [ ] **TT-04.b** `load` on a non-existent file returns `[]`. _(04-AC-4)_
- [ ] **TT-04.c** `load` on a file containing invalid JSON returns `[]` (no throw/crash).
  _(04-AC-5)_
- [ ] **TT-04.d** `save` into a directory that doesn't exist creates it and writes.
  _(04-AC-6)_
- [ ] **TT-04.e** Multiple rapid `save` calls within the debounce window result in a
  single `performWrite` (assert via a subclass/hook or by inspecting write count).
  _(04-AC-8)_

## Verification

`make test` passes `PersistenceTests`. Manual: copy items, quit the app, relaunch →
history is intact. Inspect `~/Library/Application Support/Latch/history.json` to confirm
content is present and well-formed.
