# 10 — Launch at Login — Tasks

- [ ] **T-10.1** Implement `LoginItemManager` with `isEnabled` (from
  `SMAppService.mainApp.status`) and `setEnabled(_:)` returning a `Result`. _(10-AC-1,
  10-AC-2, 10-AC-3, 10-AC-4)_
- [ ] **T-10.2** Provide the `loginItemBinding` used by `PreferencesView`, re-reading
  status on set and surfacing failures non-fatally. _(10-AC-4, 10-AC-5)_
- [ ] **T-10.3** Construct `LoginItemManager` in `AppDelegate` and pass it to
  `PreferencesView`. _(10-AC-5)_

## Verification (manual, on a Mac)

- [ ] Toggle launch-at-login ON in Preferences → Latch appears in System Settings →
  General → Login Items. _(10-AC-1, 10-AC-5)_
- [ ] Log out and back in (or restart) → Latch launches automatically. _(10-AC-1)_
- [ ] Toggle OFF → Latch removed from Login Items; does not auto-launch. _(10-AC-2)_
- [ ] If registration fails (e.g. unsigned build needing approval), the app does not crash
  and the toggle reflects the real status. _(10-AC-4)_

> Dev-build note: for reliable login-item behavior, run from `/Applications` with a signed
> build; unsigned builds may show "needs approval" in Login Items.
