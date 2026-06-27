import Foundation
import Combine
import LatchEngine

/// Drives the history panel: query + filter chip → results, selection, and actions
/// (copy-back, pin, delete). See specs/08-history-window.
final class HistoryViewModel: ObservableObject {
    enum ClipFilter: String, CaseIterable, Identifiable {
        case all, pinned, link, text, code, color
        var id: String { rawValue }
        var label: String {
            switch self {
            case .all: return "All"
            case .pinned: return "Pinned"
            case .link: return "Links"
            case .text: return "Text"
            case .code: return "Code"
            case .color: return "Colors"
            }
        }
    }

    @Published var query: String = "" { didSet { recompute() } }
    @Published var filter: ClipFilter = .all { didSet { recompute() } }
    @Published private(set) var results: [ClipItem] = []
    @Published var selectionIndex: Int = 0
    @Published var toast: String? = nil
    /// Bumped whenever the search field should (re)claim focus — on each panel open and on
    /// the in-panel "focus search" key. The panel view observes this to set focus.
    @Published var focusTick: Int = 0

    /// Set by the controller to dismiss the panel after a paste.
    var onActivate: (() -> Void)?
    /// Set by the app to play a sound on copy when enabled.
    var onCopySound: (() -> Void)?

    private let store: HistoryStore
    private let matcher: FuzzyMatcher
    private let pasteboard: PasteboardWriting
    private var cancellables = Set<AnyCancellable>()

    init(store: HistoryStore, matcher: FuzzyMatcher, pasteboard: PasteboardWriting) {
        self.store = store
        self.matcher = matcher
        self.pasteboard = pasteboard
        store.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.recompute() }
            .store(in: &cancellables)
        recompute()
    }

    var selectedItem: ClipItem? {
        guard results.indices.contains(selectionIndex) else { return nil }
        return results[selectionIndex]
    }

    func recompute() {
        let narrowed = store.items.filter { matches(filter, $0) }
        results = matcher.filter(narrowed, query: query)
        clampSelection()
    }

    func resetForShow() {
        query = ""
        filter = .all
        selectionIndex = 0
        toast = nil
        recompute()
        focusSearch()
    }

    /// Ask the panel to focus the search field (so typing immediately searches).
    func focusSearch() {
        focusTick &+= 1
    }

    func moveSelection(by delta: Int) {
        guard !results.isEmpty else { return }
        selectionIndex = min(max(selectionIndex + delta, 0), results.count - 1)
    }

    /// Cycle the active filter chip (Tab / Shift+Tab).
    func cycleFilter(by delta: Int) {
        let all = ClipFilter.allCases
        guard let i = all.firstIndex(of: filter) else { return }
        let next = (i + delta + all.count) % all.count
        filter = all[next]
    }

    /// Copy the selected (or Nth) clip back to the pasteboard, then dismiss.
    @discardableResult
    func activate(index: Int? = nil) -> Bool {
        if let i = index { selectionIndex = i }
        guard let item = selectedItem else { return false }
        pasteboard.write(item)
        onCopySound?()
        flash("Copied — paste with ⌘V")
        onActivate?()
        return true
    }

    func deleteSelected() {
        guard let item = selectedItem else { return }
        let idx = selectionIndex
        store.remove(id: item.id)
        selectionIndex = min(idx, max(results.count - 2, 0))
    }

    func togglePinSelected() {
        guard let item = selectedItem else { return }
        store.togglePin(id: item.id)
    }

    // MARK: - Helpers

    private func matches(_ filter: ClipFilter, _ item: ClipItem) -> Bool {
        switch filter {
        case .all: return true
        case .pinned: return item.pinned
        case .link: return item.type == .link
        case .text: return item.type == .text
        case .code: return item.type == .code
        case .color: return item.type == .color
        }
    }

    private func clampSelection() {
        if results.isEmpty { selectionIndex = 0 }
        else { selectionIndex = min(selectionIndex, results.count - 1) }
    }

    private func flash(_ message: String) {
        toast = message
    }
}
