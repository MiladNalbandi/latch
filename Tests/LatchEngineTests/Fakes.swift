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
@testable import LatchEngine

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
