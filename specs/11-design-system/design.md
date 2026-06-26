# 11 — Design System — Design

## Files

```
Sources/LatchApp/DesignSystem/Palette.swift       # colors (+ accent override)
Sources/LatchApp/DesignSystem/Typography.swift    # font helpers
Sources/LatchApp/DesignSystem/Metrics.swift        # radii, spacing, panel sizes
Sources/LatchApp/DesignSystem/Elevation.swift      # shadows, insets, keycap style
Sources/LatchApp/DesignSystem/VisualEffectView.swift # NSVisualEffectView wrapper
Sources/LatchApp/DesignSystem/Motion.swift         # durations + springs (reduce-motion aware)
Sources/LatchApp/DesignSystem/PBadge.swift
Sources/LatchApp/DesignSystem/PKbd.swift
Sources/LatchApp/DesignSystem/PButton.swift
Sources/LatchApp/DesignSystem/PIconButton.swift
Sources/LatchApp/DesignSystem/PSearchField.swift
Sources/LatchApp/DesignSystem/PSwitch.swift
Sources/LatchApp/DesignSystem/PCard.swift
Sources/LatchApp/DesignSystem/ClipRow.swift
```

## Palette (from /design/tokens/colors.css)

```swift
extension Color {
    init(hex: UInt32)   // 0xRRGGBB helper
}

enum Palette {
    // paper
    static let paper0   = Color(hex: 0xFFFFFF)
    static let paper50  = Color(hex: 0xFBFAF6)
    static let paper100 = Color(hex: 0xF4F2EC)
    static let paper200 = Color(hex: 0xEBE8DF)
    static let line     = Color(hex: 0xE4E1D8)
    static let lineStrong = Color(hex: 0xD4D0C4)
    // ink ramp
    static let ink900 = Color(hex: 0x11141A); /* …800/700/600/500/400/300/200/100 */
    // green
    static let green700 = Color(hex: 0x0A6A4A); static let green600 = Color(hex: 0x0E8C63)
    static let green500 = Color(hex: 0x12A877); static let green100 = Color(hex: 0xD6F2E6)
    static let green50  = Color(hex: 0xECFAF3)
    // accent/secure/danger
    static let amber500 = Color(hex: 0xF2A52C)
    static let blue500  = Color(hex: 0x2F6FED); static let blue600 = Color(hex: 0x1F55C9)
    static let blue100  = Color(hex: 0xDBE7FC)
    static let red500   = Color(hex: 0xE5484D)
    static let inkSurface = Color(hex: 0x181C23); static let inkSurface2 = Color(hex: 0x20252E)

    // semantic
    static var primary: Color { AccentStore.shared.color }   // accent-overridable (11-AC-9)
    static let primaryHover = green600, primaryPress = green700, primaryTint = green100
    static let textStrong = ink900, textBody = Color(hex:0x2B313B)
    static let textMuted  = Color(hex:0x5A626E), textFaint = Color(hex:0x7A828D)
    static let secure = blue500, danger = red500, accent = amber500
}
```

`AccentStore` is an `ObservableObject` holding the chosen accent (default Latch green);
feature 09's accent picker writes it; views read `Palette.primary` through it (11-AC-9).

## Typography (system fonts)

```swift
enum Typo {
    static func ui(_ size: CGFloat, _ w: Font.Weight = .regular) -> Font { .system(size: size, weight: w) }
    static func mono(_ size: CGFloat, _ w: Font.Weight = .medium) -> Font { .system(size: size, weight: w, design: .monospaced) }
    static func display(_ size: CGFloat) -> Font { .system(size: size, weight: .bold, design: .rounded) }
    static let eyebrow = ui(11, .bold) // + uppercase + tracking(0.08em) at call site
}
```
Tracking applied via `.tracking(_:)`; display uses `.rounded` to echo Bricolage's warmth.

## Metrics / Elevation / Motion

```swift
enum Radius { static let control=10.0, card=14.0, panel=16.0, keycap=7.0, sm=6.0; static let full=999.0 }
enum Space  { /* 2,4,6,8,12,16,20,24,32… */ ; static let panelWidth=720.0, listPane=322.0, bodyHeight=366.0 }
enum Shadow { static let sm=…, md=…, lg=…, panel=(color:.., radius:40, y:28) } // Color+radius+offset tuples
enum Motion { static let fast=0.14, base=0.20; static func spring(reduce:Bool)->Animation }
```
`Shadow.panel` ≈ `0 28px 80px rgba(17,20,26,0.30)`; applied via `.shadow`. Keycap = paper
fill, `Radius.keycap`, 1px line border with a 2px-darker bottom edge (overlay).

## VisualEffectView (frosted glass — 11-AC-5)

```swift
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blending: NSVisualEffectView.BlendingMode = .behindWindow
    // makeNSView/updateNSView set material, blendingMode, state = .active
}
```
Panel background = `VisualEffectView(.hudWindow)` with a warm paper tint overlay at low
opacity; footer = `.underWindowBackground` tinted toward `inkSurface`.

## Components (mirroring /design/components)

- **PKbd(keys:tone:size:)** — splits "cmd+shift+V" / arrays into caps; `GLYPH` map ⌘⇧⌥⌃↩⎋
  ↑↓⌫⇥; tones: default (paper), `go` (green fill), `ink` (dark). Keycap styling per Elevation.
- **PButton(title:variant:size:icon:action:)** — variants set bg/fg/border per Button.jsx;
  `.scaleEffect(pressed ? 0.97 : 1)`.
- **PBadge(text:tone:dot:icon:)** — pill; tones map to tinted bg + colored fg.
- **PSearchField(text:placeholder:)** — sunken rounded field, leading magnifier, focus ring
  in `primary`; autofocus support.
- **PSwitch(isOn:)** — capsule track, spring knob slide; on = `primary`.
- **PIconButton / PCard** — ghost-hover icon button; soft card with `Shadow.sm` + `line`.
- **ClipRow(item:selected:index:)** — see ClipItem.jsx: 38px tile colored per type
  (link→secure tint/blue, code→ink-surface/green-300, color→swatch, else paper),
  content (mono for code/link, ellipsis), meta "**source** · time", amber pin glyph, and a
  1–9 keycap shown when `selected`/hovered.

## Edge cases / notes

- Reduce Motion: `Motion.spring(reduce:)` returns `.easeOut` (no overshoot); entrance-only.
- Accent recolor should snap (avoid mid-transition stick) — animate value, not a one-frame
  flash.
- All components are pure SwiftUI; previewable in isolation for visual QA.
