# Contributing to Latch

Thanks for working on Latch. This guide covers the local setup, the quality gates, and the
conventions we follow. Read [`ARCHITECTURE.md`](ARCHITECTURE.md) first for the big picture.

## Prerequisites (macOS)

- macOS 13+ and Xcode 16 (the project format requires Xcode 16; CI uses `macos-15`).
- Tools: `brew install xcodegen swiftlint swiftformat`

## Everyday commands

```sh
make gen           # generate Latch.xcodeproj from project.yml (gitignored)
make build         # build the app
make test          # run engine unit tests
make run           # build + launch the app

make format        # apply SwiftFormat
make format-check  # verify formatting (CI mode)
make lint          # run SwiftLint
make check         # format-check + lint + build + test  (run before pushing)
```

`project.yml` is the source of truth — never hand-edit the generated `.xcodeproj`. After
the first `make gen` on your Mac, commit the resolved
`Package.resolved` (see `README.md`) to pin the `KeyboardShortcuts` version.

## Quality gates

CI (`.github/workflows/ci.yml`) must be green:

- **build-test** — builds `LatchApp` and runs `LatchEngineTests` on `macos-15`. This is the
  blocking gate.
- **lint** — SwiftFormat (`--lint`) + SwiftLint. Blocking. Run `make format` + `make lint`
  locally before pushing.

Run `make check` locally before pushing to catch all of the above.

## Coding conventions

These mirror the rules in [`ARCHITECTURE.md`](ARCHITECTURE.md):

- **Respect the layering.** `LatchEngine` must not import or reference `LatchApp`. Put
  testable logic in the engine; keep `LatchApp` to presentation + OS glue.
- **Hide OS APIs behind protocols.** Any new `NSPasteboard`/`NSWorkspace`/Keychain/etc.
  touchpoint gets a protocol in the engine and a single adapter, so it can be faked in tests.
- **Inject dependencies.** Construct concrete types only in `AppDelegate`; pass them via
  initializers. Avoid new global singletons.
- **Main-thread state.** Store and UI mutations happen on the main thread. Background work
  hops back to main before touching `HistoryStore`.
- **No magic numbers in UI.** Use the design tokens (`Palette`, `Typo`, `Radius`, `Space`,
  `Elevation`) and the `P*` / `ClipRow` components.
- **Privacy is non-negotiable.** No network/analytics. Filter concealed/transient types
  before reading content. Keep history encrypted at rest.
- **Tests with logic.** New engine behavior ships with hermetic tests (no real Keychain/
  filesystem/pasteboard) in `Tests/LatchEngineTests`.
- **Style.** SwiftFormat + SwiftLint own formatting and lint; don't fight them. 4-space
  indent, 120-col soft wrap.

## Specs-first workflow

Latch is developed spec-first. For a non-trivial feature, add or update its folder under
`specs/<NN-feature>/` (`requirements.md` EARS criteria → `design.md` → `tasks.md`) before
implementing, and tag tasks to the acceptance-criteria IDs they satisfy.

## Commits & branches

- Work on a feature branch; do not push directly to `main`.
- Write clear, imperative commit subjects with a short body explaining *why*.
- Keep commits scoped to one logical change; reference the spec/feature where relevant.
- Open a PR; ensure CI is green and `make check` passes locally.
