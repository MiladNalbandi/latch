# Latch — Design System

> The friendly, private clipboard for macOS. Copy once, paste anywhere — with one keystroke, and nothing ever leaves your Mac.

This design system defines Latch's brand, visual foundations, components, and high-fidelity recreations of its two surfaces (the macOS app and the marketing website).

## Sources

No external codebase, Figma, or brand assets were provided — Latch is established **here**, from the product brief: *"a friendly and secure clipboard with good shortcuts for macOS."* Everything below is original to this system. If a real Latch codebase or Figma later exists, link it here so future contributors can reconcile.

---

## Product context

**Latch** is a Mac menu-bar utility that records your clipboard history and brings any past copy back instantly. Two surfaces are represented:

1. **The app** (`ui_kits/app/`) — a floating, Spotlight-style panel opened with **⌘⇧V**: search, type filters, a scrollable history of `ClipItem` rows, a preview/action pane, and a keyboard-first footer. Plus a macOS-style **Settings** window (General / Privacy / Sync).
2. **The website** (`ui_kits/website/`) — the marketing landing page: hero with a live panel mock, features, a dark security section, pricing, footer.

The product's two core promises drive every design choice:
- **Friendly** — warm paper canvas, soft radii, plain-spoken copy, a gentle spring on motion.
- **Secure** — "Local only" is shown, not buried; a supporting blue + shield motif; privacy is a feature, not fine print.

---

## Content fundamentals

**Voice: friendly, plain, quietly reassuring.** Latch talks like a calm, competent friend — never a marketer, never a robot.

- **Person & address:** Speak to the user as **"you"**; the product is **"Latch"** (or implicitly "we" only in support contexts). "Hit ⌘⇧V to bring it back."
- **Casing:** Sentence case everywhere — buttons, headings, menus, settings rows. Never Title Case UI, never ALL CAPS except the tiny tracked eyebrow/overline label.
- **Tone:** Warm and concrete. Short sentences. Lead with the benefit, then the mechanism. Reassure about privacy in human terms, not jargon.
- **Do say:** "Copied. It's in your history." · "Nothing leaves your Mac." · "Hit ⌘⇧V to bring it back." · "Keep the last 200 copies a keystroke away."
- **Don't say:** "Operation completed successfully." · "Military-grade encryption!!!" · "Leverage your clipboard workflow." · "Synergy", "seamless", "revolutionary".
- **Numbers & keys:** Real numbers (200 clips, $3/mo, 0 bytes), never vague superlatives. Shortcuts are written as glyphs in keycaps (⌘⇧V), never "Command-Shift-V" in body UI.
- **Emoji:** Not used in product UI or marketing. The brand expresses warmth through copy, color, and the keycap motif — not emoji.
- **Punctuation:** Em dashes for asides, occasional exclamation only when genuinely delighted ("talk Thursday!"). No exclamation in system/status text.

---

## Visual foundations

**Overall vibe:** a refined native-macOS utility with warmth — think a calmer, friendlier Raycast/Spotlight. Frosted floating panels over a colorful desktop; light paper surfaces; the keyboard shortcut treated as a first-class brand object.

### Color
- **Canvas is warm paper**, not cold white: `--paper-50 #fbfaf6` for app/site backgrounds, `--paper-0 #fff` for cards.
- **Text is cool ink** (`--ink-900 #11141a` strong → `--ink-500` muted) — the warm/cool contrast keeps things lively.
- **Primary is "Latch green" `#12a877`** — signals go / secure / calm, friendly without being childish. Hover darkens to `--green-600`, press to `--green-700`.
- **Amber `#f2a52c`** is the accent/highlight (pins, "most popular", warm glow). **Secure-blue `#2f6fed`** is the supporting color for locks, encryption, "Local only", info.
- **Semantics:** success = green, warning = amber, danger = red `#e5484d`, info/secure = blue.
- **Imagery/backgrounds:** the app desktop uses a rich green→teal gradient wallpaper with a soft amber glow (warm, never bluish-purple). Marketing sections alternate warm paper with one **dark ink section** (`--ink-surface #181c23`) for security — the only heavy dark moment.

### Type
- **Display — Bricolage Grotesque** (700–800), tight tracking (−0.02em), tight leading (~1.05). Headlines, hero numbers, feature titles.
- **UI/Body — Hanken Grotesk** (400–700), 15px base, 1.5 leading. Calm and legible.
- **Mono — JetBrains Mono** (500–600). Keycaps, shortcuts, hashes, timestamps, code clips, prices' tabular feel.
- Eyebrows/overlines: 11px, 700, uppercase, `+0.08em` tracking, usually green.

### Spacing & layout
- **4px base grid.** Control padding ~8–14px; section padding 72–80px on the site.
- Containers max ~1120px. The app panel is a fixed ~720px float.
- Generous whitespace; content is never dense except the intentionally-scannable clip list.

### Radii
- Soft and macOS-leaning: cards 14px, panels 16px, controls 10px, keycaps 7px. Pills (badges/filters) are fully round. Nothing sharp; nothing fully pill except chips.

### Shadows & elevation
- Soft, warm-neutral, layered, low-opacity cool-ink shadows. `--shadow-sm` for resting cards, `--shadow-md/lg` for raised, `--shadow-xl` for modals, and a dramatic **`--shadow-panel`** for the floating clipboard panel.
- **Keycaps** get a 2px bottom border + subtle drop for a pressable, 3D feel.
- Fields use a faint **inset** shadow to read as sunken.

### Borders
- Hairline `--line #e4e1d8` on paper; `--line-strong` for inputs/keycaps. Dark surfaces use `--ink-line` (white at 8%).

### Transparency & blur
- **Frosted glass** is reserved for floating chrome: the menu bar and the clipboard panel use `backdrop-filter: blur(...)` over the wallpaper. Body content is solid — blur signals "floating / system-level", not decoration.

### Motion
- Snappy and native: 140–200ms, `--ease-out` (decisive settle) as default. The panel and toasts use a gentle spring (`--ease-spring`) — a small overshoot, never a cartoon bounce.
- **Hover:** subtle background tint (`--paper-100`) or a 2px card lift; links shift to green. **Press:** quick scale to **0.97**. Switches slide with the spring.
- No infinite/looping decorative animation. Respects reduced-motion intent (entrance-only).

### The keycap motif
Latch's signature object. Shortcuts are rendered as real keycaps (`Kbd`): mono type, paper cap, 2px bottom border, the operative key tinted green (`tone="go"`) or inverted on dark chrome (`tone="ink"`). The shortcut *is* the product, so it appears in the hero, the footer of every panel, the settings, and the marketing site.

---

## Iconography

- **System: Lucide** — clean 24×24, 2px-stroke, round-cap/join line icons. Chosen for its friendly-but-precise feel that matches a native Mac utility. (Substitution note: no brand icon set was provided; Lucide is the closest fit and is the documented standard.)
- **Delivery:** `ui_kits/app/Icons.js` provides the used glyphs as inline React components (`window.LatchIcons`) so the kits render **offline** with no CDN dependency, at exact Lucide proportions. For production, `lucide-react` (or the Lucide CDN) is the drop-in equivalent — keep size 16–20 and stroke 2.
- **Type glyphs** in `ClipItem` map to Lucide icons (link → Link, code → Code, image/color → Image, file → File, text → Type).
- **No emoji** as icons. **No Unicode-glyph icons** except the Mac modifier symbols inside keycaps (⌘ ⇧ ⌥ ⌃ ↩ ⎋ ↑↓), which are intentional and platform-native.
- **Logo:** `assets/latch-mark.svg` (rounded keycap with a clasp/latch glyph), `assets/latch-wordmark.svg` (mark + "Latch" in Bricolage), and `latch-wordmark-onink.svg` for dark surfaces.

---

## Index / manifest

**Root**
- `styles.css` — global entry point (consumers link this). `@import`s only.
- `readme.md` — this guide.
- `SKILL.md` — portable Agent-Skill wrapper.

**`tokens/`** — `fonts.css`, `colors.css`, `typography.css`, `spacing.css`, `radius.css`, `shadows.css`, `motion.css`.

**`assets/`** — `latch-mark.svg`, `latch-wordmark.svg`, `latch-wordmark-onink.svg`.

**`components/`** (namespace `window.LatchDesignSystem_fe0ecb`)
- `core/` — `Button`, `IconButton`, `Input`, `Switch`, `Badge`, `Card`, `Kbd`.
- `clipboard/` — `ClipItem` (the signature history row).

**`ui_kits/`**
- `app/` — macOS clipboard panel + settings (interactive desktop scene).
- `website/` — marketing landing page.

**`guidelines/`** — foundation specimen cards (Colors, Type, Spacing, Brand) shown in the Design System tab.

---

## Using the system

Consumers link one file and read components from the namespace:

```html
<link rel="stylesheet" href="styles.css">
<script src="_ds_bundle.js"></script>
<script>
  const { Button, Kbd, ClipItem } = window.LatchDesignSystem_fe0ecb;
</script>
```

All styling flows from CSS custom properties — reference tokens (`var(--primary)`, `var(--font-display)`) rather than hard-coding values.
