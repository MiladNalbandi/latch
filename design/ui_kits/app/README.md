# Latch App — UI kit

High-fidelity recreation of the Latch macOS app: the floating clipboard panel and the settings window, in an interactive desktop scene.

## Open
`index.html` — a faux macOS desktop. Click the menu-bar clipboard icon (or press **⌘⇧V**) to toggle the panel; the gear opens Settings.

## Files
- `index.html` — desktop scene, all kit CSS, script wiring.
- `Desktop.jsx` — menu bar + scene orchestration (`window.LatchDesktop`).
- `LatchPanel.jsx` — the Spotlight-style history panel: search, type filters, list, preview pane, keyboard nav, paste toast (`window.LatchPanel`).
- `LatchSettings.jsx` — preferences window with General / Privacy / Sync tabs (`window.LatchSettings`).
- `Icons.js` — Lucide-style line icons (`window.LatchIcons`). Shared with the website kit.
- `data.js` — sample clipboard history (`window.LATCH_CLIPS`).

## Composition
Built entirely from DS primitives — `ClipItem`, `Input`, `Kbd`, `Badge`, `Button`, `IconButton`, `Switch` — loaded from `_ds_bundle.js` as `window.LatchDesignSystem_fe0ecb`. Layout/scene CSS is local; everything visual references DS tokens.

## Interactions
- Type in search → filters as you go.
- Filter pills (All / Pinned / Links / Text / Code / Colors).
- ↑/↓ to move selection, ↩ to "paste" (toast), click a row to paste, hover to preview.
- Pin / unpin / delete from the preview pane.
- Gear → Settings; toggles are live; Esc / red light closes.

## Accent color (follows macOS)
Settings → General → **Appearance** has the macOS system-accent swatches (Latch / Blue / Purple / Pink / Red / Orange / Yellow / Graphite). Picking one live-recolors selection, controls, switches, the default button, and the menu-bar icon — exactly like changing the accent in System Settings → Appearance. Semantic colors (the secure-blue "Local only") intentionally stay put. The choice persists in `localStorage["latch-accent"]`.

Implementation: every accent shade is derived from a single `--primary` (set on the `.desk` root via `color-mix`), so one value cascades everywhere. A one-frame transition suppression (`.latch-no-transition`) is applied on change so var-based colors snap instead of sticking mid-transition.
