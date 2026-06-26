# 13 — Pinning & Lifecycle — Design

## Files / touch points

```
Sources/PastaEngine/HistoryStore.swift   # pin/unpin, pinned-aware ordering + eviction
Sources/PastaEngine/ClipboardMonitor.swift # isPaused (incognito)
Sources/PastaApp/LockMonitor.swift        # screen-lock observer
Sources/PastaApp/AppDelegate.swift        # wiring
```

## Pinning (HistoryStore)

`ClipItem.pinned: Bool` (feature 03). Ordering is computed on every mutation:

```swift
func sortItems() {
    items.sort { a, b in
        if a.pinned != b.pinned { return a.pinned && !b.pinned }   // pinned first (13-AC-2)
        return a.createdAt > b.createdAt                            // recent first
    }
}
func togglePin(id: UUID) { /* flip pinned, re-sort, scheduleSave (13-AC-1) */ }
```

Cap eviction skips pinned (13-AC-3):

```swift
func enforceCap() {
    let unpinned = items.filter { !$0.pinned }
    guard unpinned.count > cap else { return }
    let removable = unpinned.suffix(unpinned.count - cap).map(\.id)
    items.removeAll { removable.contains($0.id) }
}
```

## Incognito (ClipboardMonitor)

```swift
var isPaused: Bool = false   // set from Preferences.incognito
// in poll(): if isPaused { lastChangeCount = pasteboard.changeCount; return }
```
Updating `lastChangeCount` while paused ensures no back-fill on resume (13-AC-6). The menu
bar shows a paused glyph/title (feature 06) while `isPaused`.

## Clear-on-lock (LockMonitor)

```swift
final class LockMonitor {
    init(onLock: @escaping () -> Void) {
        DistributedNotificationCenter.default().addObserver(
            forName: .init("com.apple.screenIsLocked"), object: nil, queue: .main) { _ in onLock() }
    }
}
```
`AppDelegate` wires `onLock = { if prefs.clearOnLock { store.clear() } }` (13-AC-4). Default
clears everything including pinned (privacy-first, 13-AC-8).

## Edge cases

- Pin then lower cap below unpinned count: only unpinned evicted; pinned preserved even if
  total > cap (13-AC-3).
- Distributed lock notification is best-effort/unsandboxed; documented as such.
- Incognito persists across launches (a `Preferences` flag); menu bar reflects it at start.
