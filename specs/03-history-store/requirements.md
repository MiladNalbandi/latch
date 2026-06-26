# 03 — History Store — Requirements

## Overview

The in-memory authority for clipboard history: holds the ordered list of `ClipItem`s,
deduplicates by content, enforces the configurable cap, and publishes changes to the UI.
It orchestrates persistence (feature 04) but the file format lives there.

## User stories

- **US-1.** As a user, I want my most recent copy at the top and older items below.
- **US-2.** As a user, copying the same thing twice should not create duplicate entries;
  it should just bump that item to the top.
- **US-3.** As a user, I want history bounded to a size I choose so it doesn't grow
  unbounded.
- **US-4.** As a user, I want to remove a single item or clear all history.

## Acceptance criteria (EARS)

- **03-AC-1.** THE SYSTEM SHALL hold history as an ordered list with the most recently
  added/used item first.
- **03-AC-2.** WHEN an item is added whose `contentHash` matches an existing item, THE
  SYSTEM SHALL move the existing item to the top and SHALL NOT create a duplicate
  (the existing item's position and `createdAt` update to reflect recency).
- **03-AC-3.** WHEN an item is added whose `contentHash` is new, THE SYSTEM SHALL insert
  it at the top.
- **03-AC-4.** WHILE the item count exceeds `historyCap`, THE SYSTEM SHALL evict the
  oldest (bottom) items until the count equals `historyCap`.
- **03-AC-5.** WHEN `historyCap` is lowered at runtime, THE SYSTEM SHALL immediately evict
  excess oldest items to satisfy the new cap.
- **03-AC-6.** THE SYSTEM SHALL publish its item list via an observable property so the UI
  updates reactively.
- **03-AC-7.** WHEN `remove(id:)` is called, THE SYSTEM SHALL delete that item; WHEN
  `clear()` is called, THE SYSTEM SHALL remove all items.
- **03-AC-8.** WHEN the item list mutates (add/remove/clear/evict), THE SYSTEM SHALL
  request a persistence save (debounced; see feature 04).
- **03-AC-9.** WHEN the store is initialized, THE SYSTEM SHALL load existing items from
  persistence and apply the current cap.

## Out of scope

- The JSON file format and atomic write mechanics (feature 04).
- Search/filtering (feature 05).
- Pinning/favorites (post-MVP).
