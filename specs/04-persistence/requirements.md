# 04 — Persistence — Requirements

## Overview

Persist the clipboard history to local disk so it survives app quit/relaunch and machine
restart (NFR-3), using a simple atomic JSON file. Provide a protocol so the store can be
tested against an in-memory fake.

## User stories

- **US-1.** As a user, I want my clipboard history to still be there after I quit and
  reopen the app or restart my Mac.
- **US-2.** As a privacy-conscious user, I want history stored only on my machine, in a
  standard, inspectable location.
- **US-3.** As a developer, I want persistence behind a protocol so the store is testable
  without touching the filesystem.

## Acceptance criteria (EARS)

- **04-AC-1.** THE SYSTEM SHALL persist history as JSON at
  `~/Library/Application Support/pasta/history.json`.
- **04-AC-2.** WHEN saving, THE SYSTEM SHALL write atomically (write to a temp file then
  replace) so a crash mid-write cannot corrupt existing history.
- **04-AC-3.** WHEN the app launches, THE SYSTEM SHALL load the persisted history if the
  file exists.
- **04-AC-4.** IF the history file is missing, THEN THE SYSTEM SHALL start with an empty
  history (no error shown).
- **04-AC-5.** IF the history file is unreadable or corrupt (decode failure), THEN THE
  SYSTEM SHALL start with an empty history and SHALL NOT crash.
- **04-AC-6.** WHEN the Application Support `pasta` directory does not exist, THE SYSTEM
  SHALL create it before writing.
- **04-AC-7.** THE SYSTEM SHALL define a `HistoryPersisting` protocol
  (`load() -> [ClipItem]`, `save(_:)`) so an in-memory fake can substitute in tests.
- **04-AC-8.** THE SYSTEM SHALL debounce saves so a burst of rapid mutations results in a
  bounded number of disk writes.

## Out of scope

- Encryption at rest (post-MVP; content is plain text/RTF on local disk like other
  clipboard managers).
- Migration/versioning of the on-disk schema beyond what `Codable` provides (post-MVP).
- iCloud / cross-device sync (explicitly out of scope per NFR-2).
