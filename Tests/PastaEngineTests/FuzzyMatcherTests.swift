import XCTest
@testable import PastaEngine

final class FuzzyMatcherTests: XCTestCase {
    let m = FuzzyMatcher()

    func testEmptyQueryPassesThrough() {
        let items = [ClipItem.text("a"), ClipItem.text("b")]
        XCTAssertEqual(m.filter(items, query: "").map(\.preview), ["a", "b"])
    }

    func testSubsequenceOrderMatters() {
        XCTAssertNotNil(m.score(query: "ace", candidate: "abcde"))
        XCTAssertNil(m.score(query: "aec", candidate: "abcde"))
    }

    func testCaseInsensitive() {
        XCTAssertNotNil(m.score(query: "ABC", candidate: "abcdef"))
    }

    func testContiguityScoresHigher() {
        let contiguous = m.score(query: "abc", candidate: "abcxx")!
        let scattered = m.score(query: "abc", candidate: "axbxc")!
        XCTAssertGreaterThan(contiguous, scattered)
    }

    func testWordBoundaryBonus() {
        let boundary = m.score(query: "hw", candidate: "hello world")!
        let inner = m.score(query: "hw", candidate: "showxworld")!
        XCTAssertGreaterThan(boundary, inner)
    }

    func testFilterMatchesSourceToo() {
        let items = [
            ClipItem(plainText: "nothing relevant", type: .text, source: "Safari"),
            ClipItem(plainText: "hello", type: .text, source: "Mail"),
        ]
        let result = m.filter(items, query: "safari")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.source, "Safari")
    }

    func testPinnedSortFirst() {
        let pinned = ClipItem(createdAt: Date(timeIntervalSince1970: 0), plainText: "abc", type: .text, pinned: true)
        let recent = ClipItem(createdAt: Date(timeIntervalSince1970: 100), plainText: "abc", type: .text, pinned: false)
        let result = m.filter([recent, pinned], query: "abc")
        XCTAssertTrue(result.first?.pinned ?? false)
    }
}
