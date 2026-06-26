# 09 — Settings — Requirements

## Overview

A macOS-style **tabbed** settings window matching the Latch design
(`/design/ui_kits/app/LatchSettings.jsx`): **General** and **Privacy** tabs (a **Sync** tab
is shown disabled / "Coming soon" — iCloud is out of scope for v0.1). Settings apply live and
persist via `UserDefaults`.

## User stories

- **US-1.** As a user, I want a familiar Settings window to tune Latch.
- **US-2.** As a user, I want to set the accent color, shortcuts, and startup behavior.
- **US-3.** As a privacy-conscious user, I want clear controls for what's captured and the
  ability to clear everything.

## Acceptance criteria (EARS)

### Window
- **09-AC-1.** THE SYSTEM SHALL provide a titled "Latch Settings" window opened from the
  status menu and the panel's gear button, with tabs **General**, **Privacy**, and a
  disabled **Sync** ("Coming soon"). Single instance; re-open brings it to front.

### General
- **09-AC-2.** THE SYSTEM SHALL present an **accent color** picker (system-accent swatches +
  Latch green default) that recolors the UI live via `AccentStore` (feature 11).
- **09-AC-3.** THE SYSTEM SHALL present a **Launch at login** switch (feature 10).
- **09-AC-4.** THE SYSTEM SHALL present a **Play a sound on copy** switch (default off);
  WHEN on, a soft system sound plays on each capture.
- **09-AC-5.** THE SYSTEM SHALL present a **Show item count in menu bar** switch (feature 06).
- **09-AC-6.** THE SYSTEM SHALL present the two shortcuts as recorders/keycaps: "Open
  clipboard history" (⌘⇧V) and "Quick-paste recent" (⌘⌥V) (features 07).

### Privacy
- **09-AC-7.** THE SYSTEM SHALL show a reassuring privacy banner ("Your clipboard never
  leaves this Mac…").
- **09-AC-8.** THE SYSTEM SHALL present **Ignore passwords** (concealed types; default on,
  feature 02), **Clear history when Mac locks** (feature 13), and **Pause capture
  (incognito)** (feature 13) switches.
- **09-AC-9.** THE SYSTEM SHALL present a **history size** control (keep last N; range
  10–1000, default 200) that applies live via `HistoryStore.setCap` (feature 03).
- **09-AC-10.** THE SYSTEM SHALL present a **Clear all history…** danger button that empties
  the store (with a confirm).

### General behavior
- **09-AC-11.** THE SYSTEM SHALL persist all settings in `UserDefaults`, load on launch, and
  apply defaults when unset; the global hotkeys persist via KeyboardShortcuts.
- **09-AC-12.** THE SYSTEM SHALL validate/clamp numeric inputs to allowed ranges.
- **09-AC-13.** Poll interval MAY be exposed as an advanced control (range 0.2–2.0s, default
  0.5) applied live via `ClipboardMonitor.setInterval` (feature 01).

## Out of scope

- iCloud sync configuration (Sync tab is a disabled placeholder).
- Themes beyond accent color; import/export of history.
