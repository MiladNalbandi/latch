# 01 — Pasteboard Monitor — Design

## Files

```
Sources/LatchEngine/ClipItem.swift
Sources/LatchEngine/PasteboardReading.swift
Sources/LatchEngine/SystemPasteboard.swift
Sources/LatchEngine/ClipboardMonitor.swift
```

## ClipItem

```swift
public struct ClipItem: Codable, Identifiable, Equatable {
    public let id: UUID
    public let createdAt: Date
    public var plainText: String?
    public var rtfData: Data?
    public var preview: String        // trimmed, single-line, truncated display string
    public var contentHash: String    // dedupe key

    public init(id: UUID = UUID(), createdAt: Date = Date(),
                plainText: String?, rtfData: Data?)
}
```

- `preview`: derived from `plainText` if present, else a plain-text rendering of the RTF;
  whitespace-collapsed and truncated (e.g. 200 chars).
- `contentHash`: stable hash over the normalized content. MVP: SHA-256 (CryptoKit) of
  `plainText ?? ""` joined with a marker + rtf byte length, or simply a hash of the
  plain-text/rtf bytes. Two copies of identical text produce the same hash.

> `createdAt`/`id` use `Date()`/`UUID()` defaults at capture time; tests pass explicit
> values to keep them deterministic.

## PasteboardReading / PasteboardWriting

```swift
public protocol PasteboardReading: AnyObject {
    var changeCount: Int { get }
    func availableTypes() -> [String]              // raw type identifiers
    func string(forType type: String) -> String?
    func data(forType type: String) -> Data?
}

public protocol PasteboardWriting: AnyObject {     // used by feature 08 copy-back
    func write(plainText: String?, rtfData: Data?)
}
```

## SystemPasteboard (the only NSPasteboard touch point)

```swift
public final class SystemPasteboard: PasteboardReading, PasteboardWriting {
    private let pasteboard: NSPasteboard
    public init(pasteboard: NSPasteboard = .general)
    // changeCount -> pasteboard.changeCount
    // availableTypes -> pasteboard.types?.map(\.rawValue) ?? []
    // string/data(forType:) -> pasteboard.string/data(forType: .init(type))
    // write(plainText:rtfData:) -> clearContents(); setString/ setData with bumped owner
}
```

## ClipboardMonitor

```swift
public final class ClipboardMonitor {
    public var onCapture: ((ClipItem) -> Void)?
    public init(pasteboard: PasteboardReading,
                filter: PrivacyFilter = .init(),     // feature 02
                interval: TimeInterval = 0.5,
                queue: DispatchQueue = .main)
    public func start()
    public func stop()
    public func setInterval(_ interval: TimeInterval)   // 01-AC-9
    public func poll()                                  // exposed for tests (manual tick)
}
```

### Polling loop

- A `DispatchSourceTimer` scheduled on `queue` fires every `interval`; each fire calls
  `poll()`.
- `poll()`:
  1. Read `pasteboard.changeCount`. If equal to `lastChangeCount`, return.
  2. Update `lastChangeCount`.
  3. `let types = pasteboard.availableTypes()`.
  4. `if filter.shouldSkip(types: types) { return }`  ← feature 02 hook.
  5. Read plain text (`string(forType: NSPasteboard.PasteboardType.string.rawValue)`)
     and RTF (`data(forType: NSPasteboard.PasteboardType.rtf.rawValue)`).
  6. If both are nil/empty → return (01-AC-5).
  7. Build `ClipItem(plainText:rtfData:)` and call `onCapture?(item)` (01-AC-6).
- `lastChangeCount` initialized to the current `changeCount` on `start()` so existing
  clipboard content isn't captured as "new" at launch (avoid a spurious first capture).
- `setInterval` reschedules the timer but preserves `lastChangeCount` (01-AC-9).

### Threading

Default `queue = .main` keeps `onCapture` delivery on the main thread for easy UI
binding. Polling work is cheap (an integer read plus, on change, a couple of pasteboard
reads), so main-thread scheduling is acceptable for MVP per NFR-4.

## Edge cases

- Pasteboard changes faster than the poll interval: only the latest state is captured
  (acceptable for a clipboard manager).
- `changeCount` can jump by more than 1; we only compare for inequality.
- Empty string copies (`""`) are treated as non-capturable (01-AC-5).
- RTF with no plain text: `preview` is derived from the RTF (see ClipItem).
