# 11 — Design System — Requirements

## Overview

Translate the Latch design system (`/design`) into a centralized SwiftUI layer — tokens
(color, type, spacing, radii, shadows, motion, materials) and reusable components — so every
pasta view renders the brand consistently instead of hard-coding values.

## User stories

- **US-1.** As a user, I want pasta to look like one cohesive, polished native-Mac app.
- **US-2.** As a developer, I want a single source of truth for colors/spacing/components so
  the UI stays consistent and is fast to build.

## Acceptance criteria (EARS)

- **11-AC-1.** THE SYSTEM SHALL define color tokens from `/design/tokens/colors.css`
  (paper, ink ramp, Latch green primary + hover/press/tint, amber accent, secure blue,
  danger red, ink-surface) as a `Palette` with semantic aliases (`primary`, `textStrong`,
  `line`, etc.).
- **11-AC-2.** THE SYSTEM SHALL define typography from `/design/tokens/typography.css`
  mapped to **system fonts**: UI → SF Pro Text, mono → SF Mono, display → SF Pro Rounded
  (bold, tight tracking), with the documented size scale (11/12/13/15/17/20/25/32).
- **11-AC-3.** THE SYSTEM SHALL define metric tokens: radii (control 10, card 14, panel 16,
  keycap 7, full), spacing (4px grid), and panel sizing (width 720, list pane 322, body
  ~366).
- **11-AC-4.** THE SYSTEM SHALL define elevation: soft cool-ink shadows (`sm/md/lg/panel`),
  a sunken inset for fields, and keycap 2px-bottom-border styling.
- **11-AC-5.** THE SYSTEM SHALL provide frosted-glass surfaces via `NSVisualEffectView`
  (an `NSViewRepresentable`) for the floating panel and footer.
- **11-AC-6.** THE SYSTEM SHALL provide motion tokens (durations 140/200/320ms, ease-out,
  a gentle spring) and SHALL respect Reduce Motion (entrance-only / no spring when set).
- **11-AC-7.** THE SYSTEM SHALL provide reusable components matching `/design/components`:
  `PBadge` (neutral/primary/secure/success/danger; dot; sm), `PKbd` (keycap row with glyph
  map ⌘⇧⌥⌃↩⎋↑↓⌫; tones default/go/ink; sm/md/lg), `PButton`
  (primary/secondary/ghost/danger/secure × sm/md/lg, optional leading icon, press-scale
  0.97), `PIconButton`, `PSearchField` (sunken, leading search glyph), `PSwitch`
  (spring slide), `PCard`.
- **11-AC-8.** THE SYSTEM SHALL provide `ClipRow` — the signature history row: 38px
  type-tile, single-line content (mono for code/link), "source · time" meta, pin marker,
  and a 1–9 index keycap shown on hover/selection.
- **11-AC-9.** WHEN the user picks an accent color (feature 09), THE SYSTEM SHALL recolor
  `primary`/selection/controls live to the chosen accent.

## Out of scope

- The marketing website kit (`/design/ui_kits/website`).
- Bundling the Bricolage/Hanken/JetBrains font binaries (system fonts substitute).
- Lucide icon set (use SF Symbols equivalents: link/code/photo/doc/textformat/etc.).
