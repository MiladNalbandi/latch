# 01 — Pasteboard Monitor — Requirements

## Overview

Detect new clipboard content by polling `NSPasteboard.general.changeCount` and capture
each new entry as a `ClipItem` containing plain text and/or RTF. This is the core
mechanic proven in the Phase 0 spike.

## User stories

- **US-1.** As a user, I want everything I copy to be captured automatically, without
  any action on my part.
- **US-2.** As a user, I want both plain-text and styled (RTF) copies preserved so I can
  paste either form back later.
- **US-3.** As a developer, I want the pasteboard access isolated behind a protocol so
  the capture logic is unit-testable without a real pasteboard.

## Acceptance criteria (EARS)

- **01-AC-1.** THE SYSTEM SHALL poll the pasteboard `changeCount` at the configured poll
  interval (default 0.5s, from Preferences).
- **01-AC-2.** WHEN the polled `changeCount` differs from the last seen value, THE SYSTEM
  SHALL treat the current pasteboard contents as a new entry to evaluate.
- **01-AC-3.** WHEN a new entry contains plain text (`public.utf8-plain-text` /
  `NSPasteboard.PasteboardType.string`), THE SYSTEM SHALL capture the plain-text value
  into the `ClipItem`.
- **01-AC-4.** WHEN a new entry contains RTF (`public.rtf` /
  `NSPasteboard.PasteboardType.rtf`), THE SYSTEM SHALL capture the RTF data into the
  `ClipItem`.
- **01-AC-5.** IF a new entry contains neither capturable plain text nor RTF, THEN THE
  SYSTEM SHALL ignore it (no `ClipItem` emitted).
- **01-AC-6.** WHEN a `ClipItem` is successfully captured, THE SYSTEM SHALL emit it via
  the `onCapture` callback exactly once.
- **01-AC-7.** THE SYSTEM SHALL access `NSPasteboard` only through the
  `PasteboardReading` protocol, so a fake pasteboard can drive the monitor in tests.
- **01-AC-8.** THE SYSTEM SHALL run polling off the UI critical path (timer on a
  dispatch source) and SHALL be startable/stoppable (`start()` / `stop()`).
- **01-AC-9.** WHEN the poll interval changes at runtime, THE SYSTEM SHALL apply the new
  interval without dropping the last-seen `changeCount` (no spurious re-capture).
- **01-AC-10.** THE SYSTEM SHALL compute a `contentHash` and a display `preview` for each
  captured `ClipItem` (used downstream for dedupe and UI).

## v0.1 (Latch) addendum — additional acceptance criteria

- **01-AC-11.** WHEN a new entry contains image data (`public.tiff`/`public.png`) and no
  usable text, THE SYSTEM SHALL capture the image (stored as PNG, large images downscaled
  to a preview thumbnail) into the `ClipItem`.
- **01-AC-12.** WHEN a new entry contains a file URL (`public.file-url`), THE SYSTEM SHALL
  capture the file reference (path + display name).
- **01-AC-13.** WHEN capturing, THE SYSTEM SHALL record the **source app** name via
  `SourceProvider` (`NSWorkspace.shared.frontmostApplication?.localizedName`) into
  `ClipItem.source`.
- **01-AC-14.** WHEN capturing, THE SYSTEM SHALL set `ClipItem.type` via `ClipClassifier`
  (feature 12) from the text/types/source.
- **01-AC-15.** WHILE incognito/paused (feature 13), THE SYSTEM SHALL not capture; see
  13-AC-5/6.

> `SourceProvider` is a protocol (`currentSourceName() -> String?`) with a `SystemWorkspace`
> impl, kept injectable for tests. Image/file capture extends `ClipItem` with `imageData`
> and `fileURL` (feature 03 data model).

## Out of scope

- Privacy filtering of concealed/transient types (feature 02 consumes the captured types).
- Storage, dedupe, and cap (feature 03).
- Rich link unfurling / OCR (post-v0.1).
