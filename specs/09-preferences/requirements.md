# 09 — Preferences — Requirements

## Overview

A minimal preferences window letting the user configure history size, poll interval, the
global hotkey, and launch-at-login. Settings apply live and persist via `UserDefaults`.

## User stories

- **US-1.** As a user, I want to choose how many items pasta remembers.
- **US-2.** As a user, I want to tune how often pasta checks the clipboard.
- **US-3.** As a user, I want to set my summon hotkey from a recorder control.
- **US-4.** As a user, I want to toggle whether pasta starts at login.

## Acceptance criteria (EARS)

- **09-AC-1.** THE SYSTEM SHALL provide a preferences window opened from the status menu
  "Preferences…" item (feature 06).
- **09-AC-2.** THE SYSTEM SHALL present a control to set the history size (`historyCap`)
  within a sane range (e.g. 10–1000), defaulting to 200.
- **09-AC-3.** WHEN the history size changes, THE SYSTEM SHALL persist it and apply it live
  via `HistoryStore.setCap(_:)` (immediate eviction if lowered).
- **09-AC-4.** THE SYSTEM SHALL present a control to set the poll interval (e.g.
  0.2s–2.0s), defaulting to 0.5s.
- **09-AC-5.** WHEN the poll interval changes, THE SYSTEM SHALL persist it and apply it
  live via `ClipboardMonitor.setInterval(_:)`.
- **09-AC-6.** THE SYSTEM SHALL present a `KeyboardShortcuts.Recorder` bound to
  `.toggleWindow` for setting the global hotkey (feature 07).
- **09-AC-7.** THE SYSTEM SHALL present a launch-at-login toggle reflecting and updating
  the login-item state (feature 10).
- **09-AC-8.** THE SYSTEM SHALL persist `historyCap` and `pollInterval` in `UserDefaults`
  and load them on launch, applying defaults when unset.
- **09-AC-9.** THE SYSTEM SHALL validate inputs and clamp out-of-range values to the
  allowed bounds rather than accepting invalid settings.

## Out of scope

- Themes/appearance, export/import of history, advanced privacy rules (post-MVP).
- A full settings scene with multiple tabs (single pane suffices for MVP).
