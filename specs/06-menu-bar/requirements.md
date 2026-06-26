# 06 — Menu Bar — Requirements

## Overview

Give pasta its menu-bar presence: an `NSStatusItem` with an icon and a menu to open the
history window, open preferences, and quit. This feature also owns app lifecycle wiring
(the `AppDelegate` that constructs and connects all engine + UI services) and ensures the
app runs as an agent (no Dock icon).

## User stories

- **US-1.** As a user, I want a small icon in the menu bar that shows pasta is running.
- **US-2.** As a user, I want a menu to open history, open preferences, and quit.
- **US-3.** As a user, I don't want pasta cluttering my Dock or app switcher.

## Acceptance criteria (EARS)

- **06-AC-1.** THE SYSTEM SHALL create an `NSStatusItem` in the system menu bar with an
  icon (an SF Symbol, e.g. `doc.on.clipboard`) on launch.
- **06-AC-2.** THE SYSTEM SHALL provide a status-item menu with at least: "Show pasta"
  (opens the history window), "Preferences…", and "Quit pasta".
- **06-AC-3.** WHEN "Show pasta" is selected, THE SYSTEM SHALL open/toggle the history
  window (feature 08).
- **06-AC-4.** WHEN "Preferences…" is selected, THE SYSTEM SHALL open the preferences
  window (feature 09).
- **06-AC-5.** WHEN "Quit pasta" is selected, THE SYSTEM SHALL flush persistence and
  terminate.
- **06-AC-6.** THE SYSTEM SHALL set the app activation policy to `.accessory` so no Dock
  icon or main menu bar appears (belt-and-suspenders with `LSUIElement`).
- **06-AC-7.** ON launch, THE SYSTEM SHALL construct and wire the core services:
  `Preferences`, `SystemPasteboard`, `JSONHistoryPersistence`, `HistoryStore` (loaded),
  `ClipboardMonitor` (with `onCapture` → `store.add`), and start the monitor.
- **06-AC-8.** WHEN the app is about to terminate, THE SYSTEM SHALL flush the history
  store's persistence (so the latest state is saved).

## v0.1 (Latch) addendum

- **06-AC-9.** WHEN "Show item count in menu bar" (feature 09) is enabled, THE SYSTEM SHALL
  display the history item count next to the status icon.
- **06-AC-10.** WHILE incognito/paused (feature 13), THE SYSTEM SHALL indicate the paused
  state in the menu bar (e.g. a dimmed/“pause” icon variant).
- **06-AC-11.** The status menu SHALL include a "Pause capturing (incognito)" toggle as a
  quick control mirroring the Settings option.

## Out of scope

- Showing the full history inline in the status menu (the panel is the surface).
- A custom-drawn status icon beyond SF Symbol + count.
