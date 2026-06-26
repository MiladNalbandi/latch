import Foundation

/// Persistence contract for the history list, behind a protocol so the store can be
/// tested with an in-memory fake. See specs/04-persistence.
public protocol HistoryPersisting {
    func load() -> [ClipItem]
    func save(_ items: [ClipItem])
    /// Force any pending (debounced) write to complete now (used on app quit).
    func flush()
}

public extension HistoryPersisting {
    func flush() {}
}

/// Encrypts the `[ClipItem]` array with AES-GCM (via `CryptoBox`) and writes it atomically
/// to `~/Library/Application Support/Latch/history.dat`. Saves are debounced.
public final class EncryptedJSONPersistence: HistoryPersisting {
    private let fileURL: URL
    private let fileManager: FileManager
    private let crypto: CryptoBox
    private let queue = DispatchQueue(label: "com.latch.persistence")
    private let debounceInterval: TimeInterval
    private var pending: DispatchWorkItem?
    /// Latest items awaiting a write; the source of truth for both the debounced write
    /// and `flush()` (so we never rely on `perform()`-ing a cancelled work item).
    private var pendingItems: [ClipItem]?

    public init(
        fileURL: URL? = nil,
        fileManager: FileManager = .default,
        crypto: CryptoBox = CryptoBox(),
        debounceInterval: TimeInterval = 0.5
    ) {
        self.fileURL = fileURL ?? EncryptedJSONPersistence.defaultURL(fileManager)
        self.fileManager = fileManager
        self.crypto = crypto
        self.debounceInterval = debounceInterval
    }

    public static func defaultURL(_ fileManager: FileManager = .default) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        return base
            .appendingPathComponent("Latch", isDirectory: true)
            .appendingPathComponent("history.dat", isDirectory: false)
    }

    public func load() -> [ClipItem] {
        guard let ciphertext = try? Data(contentsOf: fileURL) else { return [] }
        guard let plaintext = try? crypto.open(ciphertext),
              let items = try? JSONDecoder().decode([ClipItem].self, from: plaintext) else {
            return []
        }
        return items
    }

    public func save(_ items: [ClipItem]) {
        queue.async { [weak self] in
            guard let self else { return }
            self.pendingItems = items
            self.pending?.cancel()
            let work = DispatchWorkItem { [weak self] in self?.writePending() }
            self.pending = work
            self.queue.asyncAfter(deadline: .now() + self.debounceInterval, execute: work)
        }
    }

    public func flush() {
        queue.sync {
            pending?.cancel()
            pending = nil
            writePending()
        }
    }

    /// Must run on `queue`. Writes the latest pending items (if any), then clears them so a
    /// stale debounced work item becomes a no-op.
    private func writePending() {
        guard let items = pendingItems else { return }
        pendingItems = nil
        write(items)
    }

    private func write(_ items: [ClipItem]) {
        let dir = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let plaintext = try? JSONEncoder().encode(items),
              let ciphertext = try? crypto.seal(plaintext) else { return }
        try? ciphertext.write(to: fileURL, options: [.atomic])
    }
}
