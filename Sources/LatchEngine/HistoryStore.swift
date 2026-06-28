// Latch — the friendly, private clipboard for macOS.
// Copyright (C) 2026 Milad Nalbandi
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import Foundation
import Combine

/// In-memory authority for clipboard history: dedupe, pinned-first ordering, cap
/// enforcement (pinned-safe), and persistence orchestration.
/// See specs/03-history-store and /13-pinning-lifecycle.
/// Used on the main thread (AppKit callbacks / main-queue capture / SwiftUI).
public final class HistoryStore: ObservableObject {
    @Published public private(set) var items: [ClipItem] = []

    private let persistence: HistoryPersisting
    private var cap: Int

    public init(persistence: HistoryPersisting, cap: Int) {
        self.persistence = persistence
        self.cap = max(1, cap)
    }

    public func load() {
        items = persistence.load()
        sortItems()
        enforceCap()
    }

    /// Load history off the main thread, then publish on the main thread. Decryption reads
    /// the AES key from the Keychain, which can block (or prompt) on first/ re-signed runs;
    /// doing it synchronously at launch would freeze the menu bar and hotkey setup. Any clips
    /// captured while loading are preserved (deduped by content).
    public func loadAsync() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let loaded = self.persistence.load()
            DispatchQueue.main.async {
                let capturedMeanwhile = self.items
                self.items = loaded
                for clip in capturedMeanwhile where !self.items.contains(where: { $0.contentHash == clip.contentHash }) {
                    self.items.append(clip)
                }
                self.sortItems()
                self.enforceCap()
            }
        }
    }

    // MARK: - Mutations

    public func add(_ item: ClipItem) {
        if let idx = items.firstIndex(where: { $0.contentHash == item.contentHash }) {
            // Dedupe: bump recency and preserve pin state; move to top.
            var existing = items.remove(at: idx)
            existing.createdAt = item.createdAt
            items.append(existing)
        } else {
            items.append(item)
        }
        sortItems()
        enforceCap()
        persistence.save(items)
    }

    public func togglePin(id: UUID) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].pinned.toggle()
        sortItems()
        persistence.save(items)
    }

    public func remove(id: UUID) {
        let before = items.count
        items.removeAll { $0.id == id }
        if items.count != before { persistence.save(items) }
    }

    public func clear() {
        guard !items.isEmpty else { return }
        items.removeAll()
        persistence.save(items)
    }

    public func setCap(_ newCap: Int) {
        cap = max(1, newCap)
        enforceCap()
        persistence.save(items)
    }

    public func flush() {
        persistence.flush()
    }

    // MARK: - Ordering & cap

    /// Pinned first, then most-recent first.
    private func sortItems() {
        items.sort { a, b in
            if a.pinned != b.pinned { return a.pinned && !b.pinned }
            return a.createdAt > b.createdAt
        }
    }

    /// Evict only the oldest *unpinned* items beyond the cap; pinned items are kept.
    private func enforceCap() {
        let unpinned = items.filter { !$0.pinned }
        guard unpinned.count > cap else { return }
        let removable = Set(unpinned.suffix(unpinned.count - cap).map(\.id))
        items.removeAll { removable.contains($0.id) }
    }
}
