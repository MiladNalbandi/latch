# 09 — Preferences — Tasks

- [ ] **T-09.1** Implement `Preferences` (engine) with clamped `historyCap` /
  `pollInterval`, ranges, defaults, and `UserDefaults` persistence. _(09-AC-2, 09-AC-4,
  09-AC-8, 09-AC-9)_
- [ ] **T-09.2** Implement `PreferencesView` with a history-size Stepper, poll-interval
  Slider, `KeyboardShortcuts.Recorder`, and launch-at-login Toggle. _(09-AC-2, 09-AC-4,
  09-AC-6, 09-AC-7)_
- [ ] **T-09.3** Apply changes live: history size → `store.setCap`, poll interval →
  `monitor.setInterval` (via Combine sinks or view closures in `AppDelegate`). _(09-AC-3,
  09-AC-5)_
- [ ] **T-09.4** Implement `PreferencesWindowController` (single titled window) opened from
  the status menu. _(09-AC-1)_
- [ ] **T-09.5** Bind the launch-at-login toggle to `LoginItemManager` (feature 10).
  _(09-AC-7)_

## Tests (PastaEngineTests — Preferences only; UI verified manually)

- [ ] **TT-09.a** Setting `historyCap` out of range clamps to bounds. _(09-AC-9)_
- [ ] **TT-09.b** Setting `pollInterval` out of range clamps to bounds. _(09-AC-9)_
- [ ] **TT-09.c** Unset defaults return 200 / 0.5; set values round-trip via a custom
  `UserDefaults(suiteName:)`. _(09-AC-8)_

## Verification (manual, on a Mac)

- [ ] Open Preferences from the menu. _(09-AC-1)_
- [ ] Lower history size below current count → oldest items immediately evicted. _(09-AC-3)_
- [ ] Change poll interval → new captures still detected at the new cadence. _(09-AC-5)_
- [ ] Record a new hotkey → it works immediately and after relaunch. _(09-AC-6)_
- [ ] Toggle launch-at-login → reflected in System Settings → General → Login Items.
  _(09-AC-7)_
