# 03 — History Store — Tasks

- [ ] **T-03.1** Make `ClipItem.createdAt` a `var` (to support recency bump on dedupe).
  _(supports 03-AC-2)_
- [ ] **T-03.2** Implement `HistoryStore` as `@MainActor ObservableObject` with
  `@Published items`, `cap`, and `persistence`. _(03-AC-1, 03-AC-6)_
- [ ] **T-03.3** Implement `add(_:)` with dedupe-move-to-top and new-item-insert-at-top.
  _(03-AC-2, 03-AC-3)_
- [ ] **T-03.4** Implement `enforceCap()` and call it after every add and on `setCap`.
  _(03-AC-4, 03-AC-5)_
- [ ] **T-03.5** Implement `remove(id:)` and `clear()`. _(03-AC-7)_
- [ ] **T-03.6** Implement `setCap(_:)` with min-1 clamp + immediate eviction. _(03-AC-5)_
- [ ] **T-03.7** Implement `load()` reading from persistence and applying the cap.
  _(03-AC-9)_
- [ ] **T-03.8** Implement debounced `scheduleSave()` invoked on every mutation.
  _(03-AC-8)_

## Tests (PastaEngineTests / HistoryStoreTests, using an in-memory FakePersistence)

- [ ] **TT-03.a** Add three distinct items → order is newest-first. _(03-AC-1, 03-AC-3)_
- [ ] **TT-03.b** Add an item, then add another with the same `contentHash` → count stays
  the same and the item is at the top. _(03-AC-2)_
- [ ] **TT-03.c** With `cap = 2`, add three items → oldest evicted, count == 2.
  _(03-AC-4)_
- [ ] **TT-03.d** `setCap(1)` on a 3-item store → count == 1 (newest kept). _(03-AC-5)_
- [ ] **TT-03.e** `remove(id:)` deletes the target; `clear()` empties the list.
  _(03-AC-7)_
- [ ] **TT-03.f** Every mutation triggers a `save` on the fake persistence (assert save
  count / last-saved snapshot). _(03-AC-8)_
- [ ] **TT-03.g** `load()` from a fake with more items than cap → trimmed to cap.
  _(03-AC-9)_

## Verification

`make test` passes `HistoryStoreTests`. Manual (after UI exists): copy several items,
confirm newest-first ordering, duplicate suppression, and cap eviction in the window.
