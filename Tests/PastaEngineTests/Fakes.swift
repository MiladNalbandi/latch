import Foundation
@testable import PastaEngine

/// A scriptable pasteboard for driving the monitor in tests.
final class FakePasteboard: PasteboardReading {
    var changeCount: Int = 0
    private var types: [String] = []
    private var strings: [String: String] = [:]
    private var datas: [String: Data] = [:]
    /// Records which content reads happened (to assert concealed content is never read).
    private(set) var stringReads: [String] = []
    private(set) var dataReads: [String] = []

    func availableTypes() -> [String] { types }

    func string(forType type: String) -> String? {
        stringReads.append(type)
        return strings[type]
    }

    func data(forType type: String) -> Data? {
        dataReads.append(type)
        return datas[type]
    }

    /// Simulate a new copy: bumps changeCount and sets the contents.
    func put(types: [String], strings: [String: String] = [:], datas: [String: Data] = [:]) {
        changeCount += 1
        self.types = types
        self.strings = strings
        self.datas = datas
    }
}

/// In-memory persistence that records saves.
final class FakePersistence: HistoryPersisting {
    var stored: [ClipItem]
    private(set) var saveCount = 0
    private(set) var lastSaved: [ClipItem] = []

    init(seed: [ClipItem] = []) { self.stored = seed }

    func load() -> [ClipItem] { stored }
    func save(_ items: [ClipItem]) { saveCount += 1; lastSaved = items; stored = items }
}

final class FakeSource: SourceProviding {
    var name: String?
    init(_ name: String? = nil) { self.name = name }
    func currentSourceName() -> String? { name }
}

extension ClipItem {
    /// Convenience for deterministic tests.
    static func text(_ s: String, at date: Date = Date(timeIntervalSince1970: 0), pinned: Bool = false, source: String? = nil) -> ClipItem {
        ClipItem(createdAt: date, plainText: s, type: .text, source: source, pinned: pinned)
    }
}
