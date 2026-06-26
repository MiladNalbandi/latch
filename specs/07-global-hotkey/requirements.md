# 07 — Global Hotkey — Requirements

## Overview

Let the user summon (and dismiss) the history window from anywhere with a global keyboard
shortcut, using Sindre Sorhus's `KeyboardShortcuts` package. The shortcut is recordable in
Preferences (feature 09) and persisted by the library.

## User stories

- **US-1.** As a user, I want to press a hotkey from any app to bring up my clipboard
  history instantly.
- **US-2.** As a user, I want to set/change that hotkey to one that doesn't conflict with
  my other shortcuts.
- **US-3.** As a user, pressing the hotkey again should dismiss the window.

## Acceptance criteria (EARS)

- **07-AC-1.** THE SYSTEM SHALL define a single global shortcut named
  `KeyboardShortcuts.Name.toggleWindow`.
- **07-AC-2.** WHEN the global shortcut is pressed AND the history window is hidden, THE
  SYSTEM SHALL show and focus the history window.
- **07-AC-3.** WHEN the global shortcut is pressed AND the history window is visible, THE
  SYSTEM SHALL hide the history window.
- **07-AC-4.** THE SYSTEM SHALL persist the chosen shortcut across launches (handled by
  the KeyboardShortcuts library via UserDefaults).
- **07-AC-5.** THE SYSTEM SHALL provide a sensible default shortcut on first launch if the
  user has not set one (e.g. ⌘⇧V), set only when no value exists.
- **07-AC-6.** THE SYSTEM SHALL register the shortcut handler once, at launch, via the
  `HotkeyManager`.

## Out of scope

- Multiple independent hotkeys (only one toggle shortcut for MVP).
- Per-action shortcuts (e.g. a separate "clear history" hotkey).
- Building a custom recorder UI (the library provides `KeyboardShortcuts.Recorder`, used
  in feature 09).
