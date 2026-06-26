# 08 — History Panel — Requirements

## Overview

The primary surface, matching the Latch design (`/design/ui_kits/app/LatchPanel.jsx`): a
floating, frosted, **720px two-pane** Spotlight-style panel. Top: search field + "Local
only" badge + Settings button. Below: filter chips. Body: a scrollable history **list**
(left) and a **preview pane** (right) with Paste / Pin / Delete actions. A dark footer shows
keyboard hints; a toast confirms actions. Fully keyboard-driven.

## User stories

- **US-1.** As a user, I press ⌘⇧V and get a fast, beautiful popup of my history I can drive
  entirely from the keyboard.
- **US-2.** As a user, I type to filter, narrow by type with chips, arrow to a clip, see a
  rich preview, and press Enter to put it back on my clipboard.
- **US-3.** As a user, I can pin or delete the selected clip, and press Esc (or click away)
  to dismiss.

## Acceptance criteria (EARS)

- **08-AC-1.** THE SYSTEM SHALL display a borderless, **frosted-glass**, floating panel
  (~720px wide) per the Latch design (`Radius.panel`, `Shadow.panel`), centered near the top
  of the screen, above other windows.
- **08-AC-2.** WHEN the panel opens, THE SYSTEM SHALL focus the search field and reset query
  + selection to the top.
- **08-AC-3.** WHILE the user types, THE SYSTEM SHALL fuzzy-filter the list (feature 05) over
  content + source and update live.
- **08-AC-4.** THE SYSTEM SHALL show a **filter-chip row** (All / Pinned / Links / Text /
  Code / Colors); selecting a chip narrows the list (feature 05); the active chip is styled
  selected.
- **08-AC-5.** THE SYSTEM SHALL render each list item as `ClipRow` (type tile, content,
  "source · time", pin marker, 1–9 index when active).
- **08-AC-6.** THE SYSTEM SHALL show a **preview pane** for the selected clip: a type badge
  (+ "Pinned" badge if pinned), timestamp, the content (a color swatch + hex for `color`;
  mono for code/link), a meta line "From **source** · N chars · 🛡 Local only", and action
  buttons **Paste**, **Pin/Unpin**, **Delete**. WHEN no clip is selected, it SHALL show an
  empty state.
- **08-AC-7.** ↓/↑ SHALL move the selection (clamped); the list SHALL scroll to keep the
  selection visible.
- **08-AC-8.** Return/Enter (or click a row, or the Paste button) SHALL copy the selected
  clip back to the pasteboard (text + RTF, or image/file as available) and hide the panel,
  showing a "Copied" toast.
- **08-AC-9.** ⌘⌫ SHALL delete the selected clip; the selection SHALL move to a valid
  neighbor.
- **08-AC-10.** Pressing a digit **1–9** SHALL activate (paste) the Nth visible clip.
- **08-AC-11.** Escape (or losing key focus / clicking elsewhere) SHALL hide the panel
  without modifying the pasteboard.
- **08-AC-12.** THE SYSTEM SHALL show a **footer** (dark glass) with keycap hints:
  `↑↓ Navigate`, `↩ Paste`, `⌘⌫ Delete`, `⎋ Close`.
- **08-AC-13.** `toggle()` SHALL show the panel if hidden (and activate the app so it can
  receive keys) and hide it if visible — the single source of truth for the hotkey
  (feature 07) and menu (feature 06).
- **08-AC-14.** WHEN a clip is re-pasted, the store's dedupe SHALL move it to the top without
  creating a duplicate.
- **08-AC-15.** WHILE a `color` clip is selected, the preview SHALL render a large swatch of
  that color with the uppercase hex string.

## Out of scope

- Auto-paste into the frontmost app (copy-back only for v0.1; footer still says "Paste").
- Multi-select, drag-and-drop, inline editing.
- Match-range highlighting.
