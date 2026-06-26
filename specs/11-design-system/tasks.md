# 11 — Design System — Tasks

- [ ] **T-11.1** `Palette.swift` — `Color(hex:)` + all tokens + semantic aliases +
  `AccentStore` for live accent. _(11-AC-1, 11-AC-9)_
- [ ] **T-11.2** `Typography.swift` — `Typo.ui/mono/display/eyebrow`. _(11-AC-2)_
- [ ] **T-11.3** `Metrics.swift` (radii/spacing/panel) + `Elevation.swift`
  (shadows/inset/keycap). _(11-AC-3, 11-AC-4)_
- [ ] **T-11.4** `VisualEffectView.swift` frosted-glass wrapper. _(11-AC-5)_
- [ ] **T-11.5** `Motion.swift` durations + reduce-motion-aware spring. _(11-AC-6)_
- [ ] **T-11.6** Components: `PBadge`, `PKbd`, `PButton`, `PIconButton`, `PSearchField`,
  `PSwitch`, `PCard`. _(11-AC-7)_
- [ ] **T-11.7** `ClipRow` signature row with type tile, meta, pin, 1–9 keycap. _(11-AC-8)_
- [ ] **T-11.8** SwiftUI `#Preview`s for each component for visual QA.

## Verification

- Build the app; open a debug "Design gallery" view (or Xcode previews) and compare each
  component to `/design/components/*.jsx` and `/design/ui_kits/app/index.html`.
- Confirm Latch green selection, keycap look, frosted panel background, accent recolor.
