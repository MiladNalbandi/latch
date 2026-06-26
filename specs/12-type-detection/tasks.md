# 12 — Type Detection — Tasks

- [ ] **T-12.1** Define `ClipType` enum with `symbolName`. _(12-AC-1)_
- [ ] **T-12.2** Implement `ClipClassifier.classify(text:types:source:)` with the
  file→image→color→link→code→text precedence. _(12-AC-2…9)_
- [ ] **T-12.3** Implement helpers: `isHexColor`, `isRGBColor`, `isSingleURL`,
  `looksLikeCode` (+ `devApps`). _(12-AC-4, 12-AC-5, 12-AC-6)_

## Tests (PastaEngineTests / ClassifierTests)

- [ ] **TT-12.a** `#12A877` and `#abc` → `.color`; `rgb(1,2,3)` → `.color`. _(12-AC-4)_
- [ ] **TT-12.b** `https://x.com/y` and `mailto:a@b.com` → `.link`; `hello world` → not
  link. _(12-AC-5)_
- [ ] **TT-12.c** `git rebase -i HEAD~3` (or source "Terminal") → `.code`. _(12-AC-6)_
- [ ] **TT-12.d** file-url type, empty text → `.file`; image type, empty text → `.image`.
  _(12-AC-2, 12-AC-3)_
- [ ] **TT-12.e** Plain sentence → `.text`. _(12-AC-7)_
- [ ] **TT-12.f** Precedence: color string also a "link-ish" → `.color` wins. _(12-AC-9)_

## Verification

`make test` passes `ClassifierTests`. Manual: copy a URL, a hex color, a shell command, a
file in Finder, an image → panel shows correct type tiles and filter chips work.
