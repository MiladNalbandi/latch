# 09 — Settings — Tasks

- [ ] **T-09.1** Extend `Preferences` (engine): `historyCap`, `pollInterval`, `soundOnCopy`,
  `showCountInMenuBar`, `ignorePasswords`, `clearOnLock`, `incognito`, `accentKey` —
  `UserDefaults`-backed, clamped, with defaults. _(09-AC-11, 09-AC-12)_
- [ ] **T-09.2** `SettingsWindowController` (single titled "Latch Settings" window) opened
  from menu + panel gear. _(09-AC-1)_
- [ ] **T-09.3** `SettingsView` tabs General / Privacy / Sync(disabled "Coming soon").
  _(09-AC-1)_
- [ ] **T-09.4** General: accent picker (→ AccentStore), launch-at-login, sound-on-copy,
  show-count, two shortcut recorders. _(09-AC-2…6)_
- [ ] **T-09.5** Privacy: banner, ignore-passwords, clear-on-lock, incognito, history-size,
  Clear-all (with confirm). _(09-AC-7…10)_
- [ ] **T-09.6** Wire live application in `AppDelegate` (cap, interval, incognito, count,
  accent, sound). _(09-AC-9, 09-AC-13)_

## Tests (LatchEngineTests — Preferences only; UI manual)

- [ ] **TT-09.a** Numeric clamp for `historyCap`/`pollInterval`. _(09-AC-12)_
- [ ] **TT-09.b** Defaults when unset (200 / 0.5 / sound off / count on / ignore-pw on);
  round-trip via `UserDefaults(suiteName:)`. _(09-AC-11)_
- [ ] **TT-09.c** Bool toggles persist and reload. _(09-AC-11)_

## Verification (manual, on a Mac) — compare to /design/ui_kits/app/LatchSettings.jsx

- [ ] Open "Latch Settings"; General/Privacy tabs render; Sync disabled. _(09-AC-1)_
- [ ] Accent picker recolors selection/controls live. _(09-AC-2)_
- [ ] Lower history size → eviction; toggle sound → tick on copy; toggle count → menu bar
  updates. _(09-AC-4, 09-AC-5, 09-AC-9)_
- [ ] Ignore-passwords / clear-on-lock / incognito behave per features 02/13. _(09-AC-8)_
- [ ] Clear all empties history after confirm. _(09-AC-10)_
