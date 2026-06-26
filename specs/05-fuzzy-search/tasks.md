# 05 — Fuzzy Search — Tasks

- [ ] **T-05.1** Implement `FuzzyMatcher.score(query:candidate:)` single-pass subsequence
  scorer with contiguity and word-boundary bonuses, returning `nil` for no match.
  _(05-AC-2, 05-AC-3, 05-AC-6)_
- [ ] **T-05.2** Implement `filter(_:query:)` with empty-query passthrough and
  score-desc / recency-desc sorting. _(05-AC-1, 05-AC-4, 05-AC-5, 05-AC-6)_
- [ ] **T-05.3** Lowercase both query and candidate for case-insensitive matching.
  _(05-AC-5)_

## Tests (PastaEngineTests / FuzzyMatcherTests)

- [ ] **TT-05.a** Empty query → `filter` returns the input array unchanged. _(05-AC-1)_
- [ ] **TT-05.b** Subsequence match: `score("ace", "abcde")` is non-nil; `score("aec",
  "abcde")` is nil (order matters). _(05-AC-2)_
- [ ] **TT-05.c** Case-insensitive: `score("ABC", "abcdef")` is non-nil. _(05-AC-5)_
- [ ] **TT-05.d** Contiguity: `score("abc", "abcxx") > score("abc", "axbxc")`. _(05-AC-3)_
- [ ] **TT-05.e** Word boundary: `score("hw", "hello world") > score("hw", "showxworld")`
  (boundary 'w' rewarded). _(05-AC-3)_
- [ ] **TT-05.f** `filter` over several items orders by score desc, then by recency for
  ties (use deterministic `createdAt`). _(05-AC-4)_

## Verification

`make test` passes `FuzzyMatcherTests`. Manual (after UI): open the window, type a few
characters, confirm relevant items surface and rank sensibly.
