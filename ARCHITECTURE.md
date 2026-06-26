# Architecture

Latch is a macOS menu-bar clipboard manager. This document describes how the code is
organized and the conventions every change should follow. For the per-feature contracts
(requirements / design / acceptance criteria) see [`specs/`](specs/README.md); for the
visual system see [`design/`](design/DESIGN-SYSTEM.md).

## Layering & dependency rule

Two modules with a **strict one-way dependency**:

```
LatchApp  ──depends on──▶  LatchEngine
(AppKit + SwiftUI UI)      (platform-light core logic)
```

- **`LatchEngine`** owns all logic worth testing: capture, classification, privacy
  filtering, the history store, encryption/persistence, fuzzy search, and preferences.
- **`LatchApp`** owns presentation and OS glue: the menu bar, the floating panel, settings,
  global hotkeys, login item, and the SwiftUI design system.
- **The engine never imports the UI.** This keeps the core reusable and unit-testable, and
  prevents UI concerns from leaking into logic. CI and code review should reject any
  `import`/reference from `LatchEngine` back into `LatchApp`.

## Boundaries are protocols (dependency inversion)

Every OS touchpoint sits behind a protocol so the logic can be driven by fakes in tests:

| Protocol | Production impl | Test impl | Purpose |
|----------|-----------------|-----------|---------|
| `PasteboardReading` / `PasteboardWriting` | `SystemPasteboard` (`NSPasteboard.general`) | `FakePasteboard` | read/write the clipboard |
| `SourceProviding` | `SystemPasteboard` (`NSWorkspace`) | `FakeSource` | frontmost-app name |
| `HistoryPersisting` | `EncryptedJSONPersistence` | `FakePersistence` | load/save history |
| `KeyStoring` | `KeychainKeyStore` | `InMemoryKeyStore` | hold the encryption key |

`NSPasteboard`/`NSWorkspace`/`Keychain` are each touched in exactly **one** small adapter.
New OS integrations follow the same pattern: define a protocol in the engine, implement it
once, inject it.

## Composition root

`AppDelegate` is the single place that constructs and wires concrete types together
(`Preferences`, `SystemPasteboard`, `EncryptedJSONPersistence`, `HistoryStore`,
`ClipboardMonitor`, controllers). Nothing else creates these singletons. Dependencies are
passed in via initializers — no global singletons except the design-system `AccentStore`
(a deliberate, UI-only theming bus).

## Data flow

```
NSPasteboard ─poll changeCount─▶ ClipboardMonitor
   │ (PrivacyFilter skips concealed/transient; incognito pauses)
   ▼
ClipClassifier → ClipItem ──▶ HistoryStore.add  (dedupe, pinned-first, pinned-safe cap)
   │                               │
   │                               ├─▶ @Published items ─▶ HistoryViewModel ─▶ SwiftUI panel
   │                               └─▶ EncryptedJSONPersistence (AES-GCM, key in Keychain)
   ▼
copy-back: PreviewPane/Enter → PasteboardWriting.write → (re-captured, dedup-to-top)
```

## Conventions

- **Concurrency.** All UI and store mutation happens on the **main thread** (AppKit
  callbacks, the main-queue capture timer, SwiftUI). Cross-thread work is confined to the
  persistence serial queue inside `EncryptedJSONPersistence`. Prefer keeping new state
  main-thread-bound; if you add background work, hop back to main before touching the store.
- **Error handling.** Engine APIs that can fail return `throws`/`Result`; UI glue surfaces
  failures non-fatally (e.g. login-item errors) and never `fatalError`s on recoverable
  paths. Persistence/crypto degrade gracefully (missing/corrupt file → empty history).
- **Privacy is a hard rule.** No network calls, analytics, or telemetry. Concealed/transient
  pasteboard types are filtered *before* content is read. History is encrypted at rest.
- **Design tokens, not magic numbers.** UI uses `Palette`, `Typo`, `Radius`, `Space`,
  `Elevation`, and the `P*`/`ClipRow` components — never hard-coded colors/sizes per view.
- **Value types by default.** Models (`ClipItem`, `ClipType`) and pure logic
  (`PrivacyFilter`, `ClipClassifier`, `FuzzyMatcher`) are `struct`s; reference types are for
  identity/lifecycle (stores, controllers, ObservableObjects).
- **Testability first.** Pure logic is exhaustively unit-tested; OS-bound code is thin and
  injected. New engine logic ships with tests in `Tests/LatchEngineTests`.

## Testing strategy

- `Tests/LatchEngineTests` covers the engine against fakes — no Keychain, filesystem, or
  pasteboard dependency at runtime (`PersistenceTests` writes to a temp dir with an
  `InMemoryKeyStore`). Tests are hermetic so they pass identically on a laptop and in CI.
- UI is verified manually against the `design/ui_kits/app` reference (see `specs/*/tasks.md`
  verification sections) plus SwiftUI previews.

## Tooling & CI

- **XcodeGen** (`project.yml`) is the source of truth; the `.xcodeproj` is generated and
  gitignored.
- **SwiftFormat** (`.swiftformat`) and **SwiftLint** (`.swiftlint.yml`) enforce style.
- **GitHub Actions** (`.github/workflows/ci.yml`) builds the app and runs engine tests on
  `macos-15`, plus a lint job. See [`CONTRIBUTING.md`](CONTRIBUTING.md) for local commands.
