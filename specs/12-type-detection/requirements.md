# 12 — Type Detection — Requirements

## Overview

Classify each captured clip into a `ClipType` (text / link / code / color / image / file)
so the panel can show the right icon tile, preview, and filter chips.

## Acceptance criteria (EARS)

- **12-AC-1.** THE SYSTEM SHALL define `ClipType { text, link, code, color, image, file }`.
- **12-AC-2.** WHEN the pasteboard provides a file URL (`public.file-url`) and no usable
  text, THE SYSTEM SHALL classify the clip as `file` (content = file name).
- **12-AC-3.** WHEN the pasteboard provides image data (`public.tiff`/`public.png`) and no
  usable text, THE SYSTEM SHALL classify the clip as `image`.
- **12-AC-4.** WHEN the clip's text matches a hex color (`#?[0-9a-fA-F]{6}` or `{3}`,
  optionally `rgb()/rgba()`), THE SYSTEM SHALL classify it as `color`.
- **12-AC-5.** WHEN the clip's text is a single well-formed URL (scheme `http(s)://`, or a
  bare domain/`mailto:`), THE SYSTEM SHALL classify it as `link`.
- **12-AC-6.** WHEN the clip's text looks like code — multi-line with code punctuation
  density, OR a known shell/command pattern, OR captured from a developer app (Terminal,
  Xcode, VS Code, iTerm) — THE SYSTEM SHALL classify it as `code`.
- **12-AC-7.** OTHERWISE THE SYSTEM SHALL classify the clip as `text`.
- **12-AC-8.** THE SYSTEM SHALL expose classification as pure logic
  (`classify(text:types:source:) -> ClipType`) unit-testable without a pasteboard.
- **12-AC-9.** Classification precedence SHALL be: file → image → color → link → code →
  text (first match wins).

## Out of scope

- OCR or semantic content understanding.
- Per-type custom parsers beyond what the panel needs (e.g. rich link unfurling).
- Detecting nested/mixed content (a clip gets exactly one type).
