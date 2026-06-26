# 05 — Fuzzy Search — Design

## Files

```
Sources/PastaEngine/FuzzyMatcher.swift
```

## FuzzyMatcher

```swift
public struct FuzzyMatcher {
    public init()

    /// Returns nil when `query` is not a subsequence of `candidate`,
    /// otherwise a score where higher = better match.
    public func score(query: String, candidate: String) -> Int?

    /// Empty query -> items unchanged (recency order).
    /// Non-empty -> matched items sorted by score desc, then recency desc.
    public func filter(_ items: [ClipItem], query: String) -> [ClipItem]
}
```

### Searchable text

Match against each item's `preview` (already whitespace-collapsed plain text), lowercased.
Query lowercased too (05-AC-5, case-insensitive).

### Scoring algorithm (subsequence with bonuses)

Walk the candidate once, advancing a query index when characters match:

```
qi = 0; score = 0; lastMatchIndex = -2; streak = 0
for (i, ch) in candidate.enumerated():
    if qi < query.count and ch == query[qi]:
        score += BASE                                  # base per matched char
        if i == lastMatchIndex + 1: streak += 1; score += CONTIGUOUS_BONUS * streak
        else: streak = 0
        if i == 0 or candidate[i-1] is wordBoundary: score += BOUNDARY_BONUS  # 05-AC-3
        lastMatchIndex = i
        qi += 1
return qi == query.count ? score : nil                 # full subsequence required (05-AC-2)
```

Suggested constants (tunable): `BASE = 1`, `CONTIGUOUS_BONUS = 4`, `BOUNDARY_BONUS = 8`.
Word boundary = previous char is whitespace or punctuation (non-alphanumeric).

> A leftmost-greedy single pass is sufficient and fast for MVP (candidates are short
> previews, lists are ≤ cap). True optimal subsequence scoring (DP) is unnecessary.

### filter(_:query:)

```
let q = query.trimmingCharacters(in: .whitespaces)
if q.isEmpty { return items }                          # 05-AC-1
return items
    .compactMap { item -> (ClipItem, Int)? in
        guard let s = score(query: q, candidate: item.preview) else { return nil }
        return (item, s)
    }
    .sorted { a, b in
        if a.1 != b.1 { return a.1 > b.1 }             # score desc (05-AC-4)
        return a.0.createdAt > b.0.createdAt           # recency desc tie-break
    }
    .map(\.0)
```

## Edge cases

- Query longer than candidate, or chars not all found in order → `nil` (excluded).
- Case differences ignored (both lowercased).
- Empty/whitespace-only query → all items unchanged (05-AC-1).
- Items whose `preview` is empty never match a non-empty query.

## Testing

Pure functions → straightforward unit tests with literal strings and small `ClipItem`
arrays (deterministic `createdAt` for tie-break assertions).
