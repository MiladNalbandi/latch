# pasta

The friendly, private clipboard for macOS. Copy once, paste anywhere — with one
keystroke, and nothing ever leaves your Mac.

`pasta` is a menu-bar utility that records your clipboard history and brings any past
copy back instantly via a frosted, Spotlight-style panel (⌘⇧V). It captures text, RTF,
images, files, links, colors, and code; skips passwords; pins favorites; and stores
everything **encrypted** on-device.

> Private repository — no license is published for v0.1.

## Status

v0.1 in development. The product is named **pasta** and adopts the **Latch** design
system (`design/`) as its visual identity.

## Build & run (macOS)

Requires a Mac with Xcode and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen      # one-time
make gen                   # generate pasta.xcodeproj (gitignored)
make build                 # build PastaApp
make test                  # run engine unit tests
make run                   # launch the app
```

`project.yml` is the source of truth; the generated `.xcodeproj` is gitignored. On first
launch the app is unsigned — right-click the `.app` → Open to bypass Gatekeeper. The
global hotkey may prompt for permission the first time.

### Pinned dependency

The only third-party dependency is
[KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts). After the first
`make gen` + resolve on your Mac, commit the generated
`pasta.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` to a tracked
path (e.g. copy it to repo root as `Package.resolved`) to pin the version for reviewers.

## Layout

```
Sources/PastaEngine/   testable core (capture, classify, store, encrypt, search)
Sources/PastaApp/      AppKit + SwiftUI UI (menu bar, panel, settings) + DesignSystem
Tests/PastaEngineTests/  engine unit tests
specs/                 spec-driven requirements/design/tasks per feature
design/                the Latch design system reference (tokens, components, kits)
```

## Architecture

`PastaApp` (UI) depends on `PastaEngine` (core); the engine never imports UI.
`NSPasteboard`/`NSWorkspace` are hidden behind protocols so the logic is unit-testable
with fakes. See `specs/README.md` for the full breakdown.
