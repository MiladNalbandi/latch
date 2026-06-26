# 08 — History Window — Requirements

## Overview

The primary UX surface: a lightweight floating window showing the clipboard history with a
search field and full keyboard control. Type to fuzzy-filter, arrow to navigate, Enter to
copy the selection back to the clipboard, Esc to dismiss.

## User stories

- **US-1.** As a user, I want a fast popup of my history that I can drive entirely from the
  keyboard.
- **US-2.** As a user, I want to type to filter, use arrow keys to pick, and press Enter to
  put an item back on my clipboard ready to paste.
- **US-3.** As a user, I want to press Esc (or click away) to dismiss the window without
  changing anything.

## Acceptance criteria (EARS)

- **08-AC-1.** THE SYSTEM SHALL display the history in a borderless, floating panel that
  appears centered (or near the menu bar) and floats above other windows.
- **08-AC-2.** WHEN the window opens, THE SYSTEM SHALL focus the search field so the user
  can type immediately.
- **08-AC-3.** WHILE the user types in the search field, THE SYSTEM SHALL filter the list
  via `FuzzyMatcher` (feature 05) and update results live.
- **08-AC-4.** THE SYSTEM SHALL show, for each item, a single-line preview (the
  `ClipItem.preview`), with the most relevant/recent item selectable.
- **08-AC-5.** WHEN the Down arrow is pressed, THE SYSTEM SHALL move the selection to the
  next item; WHEN the Up arrow is pressed, to the previous item; selection SHALL clamp at
  the list ends.
- **08-AC-6.** WHEN Return/Enter is pressed (or an item is clicked/double-clicked) with a
  selection, THE SYSTEM SHALL write that item back to the pasteboard (plain text and RTF
  as available) and SHALL hide the window.
- **08-AC-7.** WHEN Escape is pressed, THE SYSTEM SHALL hide the window without modifying
  the pasteboard.
- **08-AC-8.** WHEN the window loses key/focus (clicks elsewhere), THE SYSTEM SHALL hide
  the window.
- **08-AC-9.** WHEN the filter query changes, THE SYSTEM SHALL reset the selection to the
  first (top) result.
- **08-AC-10.** `toggle()` SHALL show the window if hidden (focused) and hide it if
  visible, providing the single source of truth used by the hotkey (feature 07) and menu
  (feature 06).
- **08-AC-11.** WHEN an item is copied back, THE SYSTEM SHALL ensure the re-copied content
  does not create a duplicate spurious entry beyond normal dedupe (it moves to top via the
  store's dedupe).

## Out of scope

- Rich previews (images/thumbnails), multi-select, drag-and-drop (post-MVP).
- Paste-on-select (synthesizing ⌘V) — requires Accessibility; MVP only copies back.
- Match-range highlighting (nice-to-have).
