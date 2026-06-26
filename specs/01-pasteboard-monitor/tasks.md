# 01 — Pasteboard Monitor — Tasks

- [ ] **T-01.1** Implement `ClipItem` with `id`, `createdAt`, `plainText`, `rtfData`,
  `preview`, `contentHash`; derive `preview` and `contentHash` in `init`. _(01-AC-10)_
- [ ] **T-01.2** Define `PasteboardReading` and `PasteboardWriting` protocols.
  _(01-AC-7)_
- [ ] **T-01.3** Implement `SystemPasteboard` adapter over `NSPasteboard.general`
  (reading + writing). _(01-AC-3, 01-AC-4, 01-AC-7)_
- [ ] **T-01.4** Implement `ClipboardMonitor` with `DispatchSourceTimer`, `start()`,
  `stop()`, `poll()`, and `onCapture`. _(01-AC-1, 01-AC-2, 01-AC-6, 01-AC-8)_
- [ ] **T-01.5** In `poll()`, capture plain text and/or RTF; ignore entries with neither.
  _(01-AC-3, 01-AC-4, 01-AC-5)_
- [ ] **T-01.6** Initialize `lastChangeCount` from the current value on `start()` to avoid
  a spurious first capture. _(01-AC-2)_
- [ ] **T-01.7** Implement `setInterval(_:)` that reschedules without resetting
  `lastChangeCount`. _(01-AC-9)_
- [ ] **T-01.8** Add a `FakePasteboard` test double in `Tests/PastaEngineTests`.
  _(supports 01-AC-7 testing)_

## Tests (PastaEngineTests / ClipboardMonitorTests)

- [ ] **TT-01.a** Driving the fake so `changeCount` increments with plain text → exactly
  one `onCapture` with matching `plainText`. _(01-AC-2, 01-AC-3, 01-AC-6)_
- [ ] **TT-01.b** RTF-only change → `onCapture` with `rtfData` set and a non-empty
  `preview`. _(01-AC-4, 01-AC-10)_
- [ ] **TT-01.c** Change with no text/RTF types → no `onCapture`. _(01-AC-5)_
- [ ] **TT-01.d** No change in `changeCount` across polls → no `onCapture`. _(01-AC-2)_
- [ ] **TT-01.e** Identical text copied twice → two captures with the same `contentHash`
  (dedupe handled later in store). _(01-AC-10)_

## Verification

Run `make test` on a Mac; all `ClipboardMonitorTests` pass. Manual: with the app running,
copy text in any app and confirm (via logging or the history window in later features)
that capture fires once per copy.
