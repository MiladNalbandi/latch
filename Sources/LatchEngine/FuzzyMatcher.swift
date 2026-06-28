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

/// Subsequence ("fuzzy") matching with contiguity and word-boundary bonuses, over a
/// clip's preview text and source app. Pure and unit-testable. See specs/05-fuzzy-search.
public struct FuzzyMatcher {
    private let base = 1
    private let contiguousBonus = 4
    private let boundaryBonus = 8

    public init() {}

    /// Returns nil when `query` is not an in-order subsequence of `candidate`,
    /// otherwise a score where higher = better.
    public func score(query: String, candidate: String) -> Int? {
        let q = Array(query.lowercased())
        guard !q.isEmpty else { return 0 }
        let c = Array(candidate.lowercased())
        guard q.count <= c.count else { return nil }

        var qi = 0
        var total = 0
        var lastMatch = -2
        var streak = 0

        for (i, ch) in c.enumerated() {
            guard qi < q.count, ch == q[qi] else { continue }
            total += base
            if i == lastMatch + 1 {
                streak += 1
                total += contiguousBonus * streak
            } else {
                streak = 0
            }
            if i == 0 || !c[i - 1].isLetterOrNumber {
                total += boundaryBonus
            }
            lastMatch = i
            qi += 1
            if qi == q.count { break }
        }
        return qi == q.count ? total : nil
    }

    /// Empty query → items unchanged (caller's order). Non-empty → matched items sorted
    /// by pinned-first, then score desc, then recency desc.
    public func filter(_ items: [ClipItem], query: String) -> [ClipItem] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return items }

        let scored: [(item: ClipItem, score: Int)] = items.compactMap { item in
            let haystacks = [item.preview, item.source ?? ""]
            let best = haystacks.compactMap { score(query: q, candidate: $0) }.max()
            guard let s = best else { return nil }
            return (item, s)
        }

        return scored.sorted { a, b in
            if a.item.pinned != b.item.pinned { return a.item.pinned && !b.item.pinned }
            if a.score != b.score { return a.score > b.score }
            return a.item.createdAt > b.item.createdAt
        }.map(\.item)
    }
}

private extension Character {
    var isLetterOrNumber: Bool { isLetter || isNumber }
}
