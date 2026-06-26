# 03 — History Store — Design

## Files

```
Sources/PastaEngine/HistoryStore.swift
```

(Depends on `HistoryPersisting` from feature 04 and `ClipItem` from feature 01.)

## HistoryStore

```swift
@MainActor
public final class HistoryStore: ObservableObject {
    @Published public private(set) var items: [ClipItem] = []

    private let persistence: HistoryPersisting
    private var cap: Int

    public init(persistence: HistoryPersisting, cap: Int)

    public func load()                       // 03-AC-9
    public func add(_ item: ClipItem)        // 03-AC-2, 03-AC-3, 03-AC-4, 03-AC-8
    public func remove(id: UUID)             // 03-AC-7, 03-AC-8
    public func clear()                      // 03-AC-7, 03-AC-8
    public func setCap(_ newCap: Int)        // 03-AC-5, 03-AC-8
}
```

### add(_:)

```
if let idx = items.firstIndex(where: { $0.contentHash == item.contentHash }) {
    var existing = items.remove(at: idx)
    existing.createdAt = item.createdAt     // bump recency (requires var createdAt or rebuild)
    items.insert(existing, at: 0)           // 03-AC-2 move-to-top, no duplicate
} else {
    items.insert(item, at: 0)               // 03-AC-3
}
enforceCap()                                // 03-AC-4
scheduleSave()                              // 03-AC-8
```

> Note: `ClipItem.createdAt` is declared `let` in feature 01. To support recency bump on
> dedupe, either (a) make `createdAt` a `var`, or (b) on match, build a replacement
> `ClipItem` preserving `id` with a new `createdAt`. Implementation picks (a) for
> simplicity; update feature 01's `ClipItem` accordingly (createdAt → `var`).

### enforceCap()

```
if items.count > cap { items.removeLast(items.count - cap) }   // 03-AC-4
```

### setCap(_:)

```
cap = max(1, newCap); enforceCap(); scheduleSave()             // 03-AC-5
```

### load()

```
items = persistence.load()
enforceCap()                                                   // 03-AC-9
```

### scheduleSave()

Debounced save to avoid thrashing the disk on bursts (e.g. many rapid copies). Detail in
feature 04; the store calls `persistence.save(items)` through a debounce (e.g. a
`DispatchWorkItem` cancel-and-reschedule with a ~0.5s delay), or delegates debouncing to
the persistence layer. The store's contract: every mutation results in an eventual save.

## Concurrency

`@MainActor` keeps `items` mutations and `@Published` emission on the main thread, which
matches `ClipboardMonitor`'s default main-queue `onCapture` delivery. The app wires
`monitor.onCapture = { item in store.add(item) }`.

## Edge cases

- Adding an item equal to the current top: still moves to top (no-op visually) and bumps
  recency; no duplicate (03-AC-2).
- `cap <= 0`: clamped to a minimum of 1 in `setCap`.
- `remove(id:)` for an unknown id: no-op (still schedules save? — only schedule save if an
  item was actually removed, to avoid needless writes).
- Loading more items than the cap (cap lowered between sessions): `load()` trims to cap.
