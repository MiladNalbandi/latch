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

import XCTest
@testable import LatchEngine

@MainActor
final class HistoryStoreTests: XCTestCase {
    private func makeStore(cap: Int = 200, seed: [ClipItem] = []) -> (HistoryStore, FakePersistence) {
        let p = FakePersistence(seed: seed)
        let s = HistoryStore(persistence: p, cap: cap)
        return (s, p)
    }

    func testNewestFirstOrdering() {
        let (s, _) = makeStore()
        s.add(ClipItem.text("a", at: Date(timeIntervalSince1970: 1)))
        s.add(ClipItem.text("b", at: Date(timeIntervalSince1970: 2)))
        s.add(ClipItem.text("c", at: Date(timeIntervalSince1970: 3)))
        XCTAssertEqual(s.items.map(\.preview), ["c", "b", "a"])
    }

    func testDedupeMovesToTopNoDuplicate() {
        let (s, _) = makeStore()
        s.add(ClipItem.text("a", at: Date(timeIntervalSince1970: 1)))
        s.add(ClipItem.text("b", at: Date(timeIntervalSince1970: 2)))
        s.add(ClipItem.text("a", at: Date(timeIntervalSince1970: 3)))
        XCTAssertEqual(s.items.count, 2)
        XCTAssertEqual(s.items.first?.preview, "a")
    }

    func testCapEviction() {
        let (s, _) = makeStore(cap: 2)
        s.add(ClipItem.text("a", at: Date(timeIntervalSince1970: 1)))
        s.add(ClipItem.text("b", at: Date(timeIntervalSince1970: 2)))
        s.add(ClipItem.text("c", at: Date(timeIntervalSince1970: 3)))
        XCTAssertEqual(s.items.count, 2)
        XCTAssertEqual(s.items.map(\.preview), ["c", "b"])
    }

    func testSetCapEvictsImmediately() {
        let (s, _) = makeStore(cap: 3)
        for i in 1...3 { s.add(ClipItem.text("\(i)", at: Date(timeIntervalSince1970: TimeInterval(i)))) }
        s.setCap(1)
        XCTAssertEqual(s.items.count, 1)
        XCTAssertEqual(s.items.first?.preview, "3")
    }

    func testPinnedFirstAndSurvivesCap() {
        let (s, _) = makeStore(cap: 2)
        s.add(ClipItem.text("old", at: Date(timeIntervalSince1970: 1)))
        let oldId = s.items.first!.id
        s.togglePin(id: oldId)
        s.add(ClipItem.text("b", at: Date(timeIntervalSince1970: 2)))
        s.add(ClipItem.text("c", at: Date(timeIntervalSince1970: 3)))
        s.add(ClipItem.text("d", at: Date(timeIntervalSince1970: 4)))
        XCTAssertTrue(s.items.contains { $0.id == oldId })   // pinned survived cap
        XCTAssertTrue(s.items.first?.pinned ?? false)        // pinned sorts first
    }

    func testRemoveAndClear() {
        let (s, _) = makeStore()
        s.add(ClipItem.text("a"))
        let id = s.items.first!.id
        s.remove(id: id)
        XCTAssertTrue(s.items.isEmpty)
        s.add(ClipItem.text("b"))
        s.clear()
        XCTAssertTrue(s.items.isEmpty)
    }

    func testEveryMutationSaves() {
        let (s, p) = makeStore()
        s.add(ClipItem.text("a"))
        let after1 = p.saveCount
        s.clear()
        XCTAssertGreaterThan(p.saveCount, after1)
    }

    func testLoadAppliesCap() {
        let seed = (1...5).map { ClipItem.text("\($0)", at: Date(timeIntervalSince1970: TimeInterval($0))) }
        let (s, _) = makeStore(cap: 3, seed: seed)
        s.load()
        XCTAssertEqual(s.items.count, 3)
    }
}
