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
/// to `~/Library/Application Support/pasta/history.dat`. Saves are debounced.
public final class EncryptedJSONPersistence: HistoryPersisting {
    private let fileURL: URL
    private let fileManager: FileManager
    private let crypto: CryptoBox
    private let queue = DispatchQueue(label: "com.pasta.persistence")
    private let debounceInterval: TimeInterval
    private var pending: DispatchWorkItem?

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
            .appendingPathComponent("pasta", isDirectory: true)
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
        pending?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.write(items) }
        pending = work
        queue.asyncAfter(deadline: .now() + debounceInterval, execute: work)
    }

    public func flush() {
        queue.sync {
            if let work = pending {
                work.cancel()
                pending = nil
                work.perform()
            }
        }
    }

    private func write(_ items: [ClipItem]) {
        let dir = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let plaintext = try? JSONEncoder().encode(items),
              let ciphertext = try? crypto.seal(plaintext) else { return }
        try? ciphertext.write(to: fileURL, options: [.atomic])
    }
}
