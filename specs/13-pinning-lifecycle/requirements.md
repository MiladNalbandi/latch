# 13 — Pinning & Lifecycle — Requirements

## Overview

Three privacy/utility behaviors from the Latch design: **pinning** items (keep them around,
sorted first), **clear-on-lock** (wipe history when the Mac locks), and **incognito pause**
(temporarily stop capturing).

## User stories

- **US-1.** As a user, I want to pin clips I reuse so they stay at the top and never fall
  off as history fills up.
- **US-2.** As a privacy-conscious user, I want history cleared automatically when my Mac
  locks.
- **US-3.** As a user, I want a quick "incognito" pause so sensitive work isn't recorded.

## Acceptance criteria (EARS)

- **13-AC-1.** THE SYSTEM SHALL let any clip be pinned/unpinned; pinned state SHALL persist.
- **13-AC-2.** THE SYSTEM SHALL sort pinned clips before unpinned ones; within each group,
  most-recent-first.
- **13-AC-3.** WHILE the history exceeds the cap, THE SYSTEM SHALL evict only the oldest
  **unpinned** clips; pinned clips SHALL NOT be evicted by the cap.
- **13-AC-4.** WHILE "clear history when Mac locks" is enabled AND the screen locks
  (`com.apple.screenIsLocked` distributed notification), THE SYSTEM SHALL clear all history.
- **13-AC-5.** WHILE incognito (pause capture) is enabled, THE SYSTEM SHALL not capture or
  store any new clips, and the menu bar SHALL indicate the paused state.
- **13-AC-6.** WHEN incognito is disabled again, THE SYSTEM SHALL resume capturing from the
  current pasteboard state without back-filling clips copied while paused.
- **13-AC-7.** The "Pinned" filter chip SHALL show only pinned clips (feature 05/08).
- **13-AC-8.** Clear-on-lock SHALL respect pinned clips per a setting: default clears
  everything including pinned (it's a privacy action); document the choice.

## Out of scope

- Per-clip expiry/TTL.
- Locking individual clips behind auth.
- Auto-incognito per app.
