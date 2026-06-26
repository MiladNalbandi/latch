# 04 — Persistence — Design

## Files

```
Sources/LatchEngine/HistoryPersisting.swift     # protocol + JSONHistoryPersistence
```

## Protocol

```swift
public protocol HistoryPersisting {
    func load() -> [ClipItem]
    func save(_ items: [ClipItem])
}
```

## JSONHistoryPersistence

```swift
public final class JSONHistoryPersistence: HistoryPersisting {
    private let fileURL: URL
    private let fileManager: FileManager
    private let queue = DispatchQueue(label: "com.latch.persistence")
    private var pendingSave: DispatchWorkItem?
    private let debounceInterval: TimeInterval

    public init(fileURL: URL = JSONHistoryPersistence.defaultURL,
                fileManager: FileManager = .default,
                debounceInterval: TimeInterval = 0.5)

    public static var defaultURL: URL {
        // ~/Library/Application Support/Latch/history.json
        // FileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, ...)
        //   .appendingPathComponent("Latch", isDirectory: true)
        //   .appendingPathComponent("history.json")
    }

    public func load() -> [ClipItem]      // 04-AC-3, 04-AC-4, 04-AC-5
    public func save(_ items: [ClipItem]) // debounced (04-AC-8) -> performWrite
    private func performWrite(_ items: [ClipItem]) // 04-AC-2, 04-AC-6
}
```

### load()

```
guard let data = try? Data(contentsOf: fileURL) else { return [] }   // 04-AC-4
guard let items = try? JSONDecoder().decode([ClipItem].self, from: data) else { return [] } // 04-AC-5
return items
```

### save(_:) — debounced

```
pendingSave?.cancel()
let work = DispatchWorkItem { [weak self] in self?.performWrite(items) }
pendingSave = work
queue.asyncAfter(deadline: .now() + debounceInterval, execute: work)   // 04-AC-8
```

### performWrite(_:)

```
let dir = fileURL.deletingLastPathComponent()
try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true) // 04-AC-6
guard let data = try? JSONEncoder().encode(items) else { return }
try? data.write(to: fileURL, options: [.atomic])                            // 04-AC-2
```

> `.atomic` writes to a temp file and renames, satisfying the crash-safety requirement.
> Encoder may set `.prettyPrinted` for human-inspectability (optional).

## Debounce ownership

Debouncing lives here in the persistence layer so the store's `scheduleSave()` can call
`persistence.save(items)` directly each mutation; rapid calls coalesce into one write
after the quiet period (04-AC-8). This keeps `HistoryStore` simple. A `flush()` may be
added so the app can force a synchronous write on `applicationWillTerminate`.

```swift
public func flush()   // cancel pending, write immediately (used on app quit)
```

## Testing

`HistoryStoreTests` uses an in-memory `FakePersistence: HistoryPersisting` (records saves,
returns a seeded array from `load()`). `JSONHistoryPersistence` itself is tested with a
temp-directory `fileURL` for round-trip, missing-file, and corrupt-file cases.

## Edge cases

- First launch: no file → `load()` returns `[]` (04-AC-4).
- Corrupt JSON: decode throws → `[]` (04-AC-5); the next save overwrites the bad file.
- App quit during debounce window: `flush()` on `applicationWillTerminate` ensures the
  last state is written.
- Application Support dir missing on a fresh account: created on first write (04-AC-6).
