# 10 — Launch at Login — Requirements

## Overview

Let pasta start automatically when the user logs in, toggled from Preferences, using the
modern `SMAppService` API (macOS 13+). A clipboard manager is only useful if it's always
running, so launch-at-login is a core MVP convenience.

## User stories

- **US-1.** As a user, I want pasta to start automatically at login so my history is always
  being captured.
- **US-2.** As a user, I want to turn that off easily if I prefer to launch it manually.
- **US-3.** As a user, I want the toggle to reflect the real current state.

## Acceptance criteria (EARS)

- **10-AC-1.** THE SYSTEM SHALL register the app as a login item via
  `SMAppService.mainApp.register()` when launch-at-login is enabled.
- **10-AC-2.** THE SYSTEM SHALL unregister via `SMAppService.mainApp.unregister()` when
  launch-at-login is disabled.
- **10-AC-3.** THE SYSTEM SHALL expose the current state derived from
  `SMAppService.mainApp.status` (enabled when `.enabled`).
- **10-AC-4.** WHEN registration or unregistration fails, THE SYSTEM SHALL surface the
  error gracefully (no crash) and leave the toggle reflecting the actual status.
- **10-AC-5.** THE SYSTEM SHALL present the toggle in Preferences (feature 09), initialized
  from the current status.

## Out of scope

- A separate bundled login-item helper (the legacy `SMLoginItemSetEnabled` approach) —
  `SMAppService.mainApp` registers the main app directly.
- "Start hidden / start minimized" options (the app is an agent; it has no main window to
  hide).
