# 08 — History Panel — Tasks

- [ ] **T-08.1** `HistoryViewModel`: query + `ClipFilter` chip + fuzzy (content+source) →
  pinned-first results; selection; toast. _(08-AC-3, 08-AC-4, 08-AC-7)_
- [ ] **T-08.2** `activate/pasteSelected` copy-back (text/RTF/image/file) + hide + toast;
  dedupe-to-top via store. _(08-AC-8, 08-AC-10, 08-AC-14)_
- [ ] **T-08.3** `deleteSelected` (⌘⌫) + neighbor reselect; `togglePinSelected`. _(08-AC-9)_
- [ ] **T-08.4** `HistoryPanelController`: frosted floating `NSPanel`, show/hide/toggle,
  activate + focus search on show, hide on resign-key. _(08-AC-1, 08-AC-2, 08-AC-11,
  08-AC-13)_
- [ ] **T-08.5** `HistoryPanel` SwiftUI: header (search + Local-only badge + settings),
  `FilterBar`, list of `ClipRow`, `PreviewPane`, dark footer with `PKbd` hints. _(08-AC-1,
  08-AC-4, 08-AC-5, 08-AC-6, 08-AC-12)_
- [ ] **T-08.6** `PreviewPane`: type/pinned badges, time, content (mono for code/link),
  color swatch+hex, meta "From source · N chars · Local only", Paste/Pin/Delete buttons,
  empty state. _(08-AC-6, 08-AC-15)_
- [ ] **T-08.7** `FilterBar` chip row with selected styling. _(08-AC-4)_
- [ ] **T-08.8** Local key monitor: ↑↓ / ↩ / ⌘⌫ / ⎋ / 1–9. _(08-AC-7, 08-AC-8, 08-AC-9,
  08-AC-10, 08-AC-11)_

## Verification (manual, on a Mac) — compare to /design/ui_kits/app

- [ ] ⌘⇧V opens a 720px frosted two-pane panel; search focused. _(08-AC-1, 08-AC-2)_
- [ ] Typing filters; chips narrow by type/pinned; ↑↓ navigate; preview updates. _(08-AC-3,
  08-AC-4, 08-AC-6, 08-AC-7)_
- [ ] Enter / 1–9 / row click copies back + toast + hides; ⌘V pastes it elsewhere.
  _(08-AC-8, 08-AC-10)_
- [ ] ⌘⌫ deletes; Pin toggles and re-sorts; color clip shows swatch + hex. _(08-AC-9,
  08-AC-15)_
- [ ] Footer shows ↑↓/↩/⌘⌫/⎋ keycaps; Esc/click-away dismisses. _(08-AC-11, 08-AC-12)_
