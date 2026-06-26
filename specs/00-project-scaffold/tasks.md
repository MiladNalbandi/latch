# 00 — Project Scaffold — Tasks

- [ ] **T-00.1** Write `project.yml` with `PastaEngine`, `PastaApp`, `PastaEngineTests`
  targets, macOS 13.0 deployment target, and schemes. _(00-AC-1, 00-AC-2, 00-AC-3)_
- [ ] **T-00.2** Set `INFOPLIST_KEY_LSUIElement: YES` and `GENERATE_INFOPLIST_FILE: YES`
  on `PastaApp`. _(00-AC-4)_
- [ ] **T-00.3** Declare the `KeyboardShortcuts` package (from 2.0.0) and add it as a
  dependency of `PastaApp`. _(00-AC-5)_
- [ ] **T-00.4** Add `Sources/PastaApp/Resources/pasta.entitlements` (empty/unsandboxed)
  and reference it via `CODE_SIGN_ENTITLEMENTS`. _(00-AC-6)_
- [ ] **T-00.5** Write the `Makefile` with `gen`, `build`, `test`, `run`, `clean`
  targets. _(00-AC-7)_
- [ ] **T-00.6** Write `.gitignore` (xcodeproj, .build, DerivedData, .DS_Store).
  _(00-AC-9)_
- [ ] **T-00.7** Write root `README.md` with Mac build steps, Package.resolved pin
  location, and private-repo note. _(00-AC-10)_
- [ ] **T-00.8** Add a minimal `@main` `AppDelegate.swift` (status-item stub, activation
  policy `.accessory`) and a placeholder `Sources/PastaEngine` file so all three targets
  compile. _(00-AC-8)_
- [ ] **T-00.9** On a Mac: `make gen && make build`; confirm `PastaApp.app` launches with
  no Dock icon. Commit a pinned `Package.resolved`. _(00-AC-8, 00-AC-5)_

## Verification

- `make gen` produces `pasta.xcodeproj` (and it is gitignored).
- `make build` succeeds; `make run` launches an app with a menu-bar presence and no Dock
  icon.
- `make test` runs the (initially empty) test bundle without error.
