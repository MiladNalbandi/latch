# 05 — Fuzzy Search — Requirements

## Overview

Filter and rank the history by a typed query using subsequence ("fuzzy") matching, so
users can find an item by typing a few characters in any position. Pure, dependency-free
logic in the engine.

## User stories

- **US-1.** As a user, I want to type a few characters and see matching history items,
  even if the characters aren't contiguous in the item text.
- **US-2.** As a user, I want the best matches (contiguous, start-of-word) ranked above
  looser ones.
- **US-3.** As a user, with no query typed, I want to see my full history in recency
  order.

## Acceptance criteria (EARS)

- **05-AC-1.** IF the query is empty, THEN THE SYSTEM SHALL return all items in their
  existing (recency) order.
- **05-AC-2.** WHEN a query is non-empty, THE SYSTEM SHALL include an item only if the
  query characters appear as an in-order subsequence of the item's searchable text
  (case-insensitive).
- **05-AC-3.** THE SYSTEM SHALL compute a match score that rewards contiguous matches and
  matches at word boundaries / start of string.
- **05-AC-4.** WHEN multiple items match, THE SYSTEM SHALL order results by descending
  score, breaking ties by recency (more recent first).
- **05-AC-5.** THE SYSTEM SHALL match against the item's `preview` (or plain-text)
  searchable text, case-insensitively.
- **05-AC-6.** THE SYSTEM SHALL expose pure functions (`score(query:candidate:) -> Int?`
  returning nil for no match, and `filter(_:query:) -> [ClipItem]`) that are
  unit-testable without UI.

## v0.1 (Latch) addendum — filters + quick-pick

- **05-AC-7.** THE SYSTEM SHALL match against the clip's content **and** its `source` app
  name (case-insensitive).
- **05-AC-8.** THE SYSTEM SHALL support a **filter chip** dimension orthogonal to the query:
  `All`, `Pinned`, `Links`, `Text`, `Code`, `Colors` (map to `ClipType`/`pinned`). The
  active filter narrows the set before fuzzy ranking.
- **05-AC-9.** Within results, **pinned** clips SHALL sort first (consistent with the store),
  then by score, then recency.
- **05-AC-10.** Pressing a number key **1–9** in the panel SHALL select/activate the Nth
  visible result (feature 08).

## Out of scope

- Highlighting matched character ranges in the UI (nice-to-have).
- Searching RTF styling or pixel content.
- Regex / token / field-scoped search (post-v0.1).
