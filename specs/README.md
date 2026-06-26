# pasta — Specifications (MVP v0.1)

`pasta` is a macOS menu-bar clipboard-history manager. This directory holds the
**spec-driven development** artifacts for MVP v0.1. Every feature has its own folder
with three files:

- **requirements.md** — user stories + acceptance criteria in [EARS](#ears-format) style.
- **design.md** — types, signatures, data flow, file paths, and edge cases.
- **tasks.md** — ordered, checkbox implementation tasks, each tagged with the
  requirement IDs it satisfies.

Specs are written and reviewed **before** any implementation. The acceptance criteria
double as the manual-QA / unit-test checklist that runs on a Mac.

## Feature index

| #  | Feature              | Folder                       | Summary                                                        |
|----|----------------------|------------------------------|---------------------------------------------------------------|
| 00 | Project scaffold     | `00-project-scaffold/`       | XcodeGen project, two targets, build tooling, entitlements    |
| 01 | Pasteboard monitor   | `01-pasteboard-monitor/`     | Poll `changeCount`, diff, capture plain text + RTF            |
| 02 | Privacy filter       | `02-privacy-filter/`         | Skip concealed / transient / auto-generated types             |
| 03 | History store        | `03-history-store/`          | In-memory items, dedupe, configurable cap, ordering           |
| 04 | Persistence          | `04-persistence/`            | Codable→JSON atomic file, load on launch, save on change      |
| 05 | Fuzzy search         | `05-fuzzy-search/`           | Subsequence scoring + filter over history                     |
| 06 | Menu bar             | `06-menu-bar/`               | `NSStatusItem` presence + menu, agent (no Dock) app           |
| 07 | Global hotkey        | `07-global-hotkey/`          | KeyboardShortcuts summon / toggle window                      |
| 08 | History window       | `08-history-window/`         | SwiftUI panel: search + keyboard nav + copy-back              |
| 09 | Preferences          | `09-preferences/`            | History size, poll interval, hotkey recorder, login toggle    |
| 10 | Launch at login      | `10-launch-at-login/`        | `SMAppService` register / unregister + toggle                 |

## Glossary

- **ClipItem** — one captured clipboard entry (plain text and/or RTF, timestamp, hash).
- **changeCount** — `NSPasteboard.changeCount`, a monotonically increasing integer that
  bumps on every system-wide pasteboard write. The cheap signal we poll.
- **Capture** — reading a new pasteboard state into a `ClipItem`.
- **Dedupe** — when new content matches an existing item's `contentHash`, the existing
  item moves to the top instead of creating a duplicate.
- **Cap** — `historyCap`, the maximum number of stored items (default 200).
- **Concealed / transient types** — `NSPasteboard` type hints used by password managers
  and other tools to mark content that should not be recorded.
- **Engine** — the `PastaEngine` target: platform-light, testable core logic.
- **Agent app** — an app with `LSUIElement = true` / activation policy `.accessory`:
  runs without a Dock icon or main menu bar, only a status-bar presence.

## Architecture (cross-cutting)

Two targets with a strict, one-way dependency:

```
PastaApp (AppKit + SwiftUI UI)  ──depends on──▶  PastaEngine (core logic)
```

- The engine **never** imports the UI layer.
- `NSPasteboard` is touched in exactly one place (`SystemPasteboard`), behind the
  `PasteboardReading` / `PasteboardWriting` protocols, so dedupe, cap, privacy, fuzzy,
  and persistence logic can be unit-tested against fakes.

```
Sources/PastaEngine/   ClipItem, PasteboardReading, SystemPasteboard, PrivacyFilter,
                       ClipboardMonitor, HistoryPersisting (+ JSONHistoryPersistence),
                       HistoryStore, FuzzyMatcher, Preferences
Sources/PastaApp/      AppDelegate, StatusItemController, HotkeyManager,
                       LoginItemManager, HistoryWindow, HistoryViewModel,
                       HistoryListView, PreferencesView, Resources/pasta.entitlements
Tests/PastaEngineTests/  PrivacyFilterTests, FuzzyMatcherTests, HistoryStoreTests,
                         PersistenceTests, ClipboardMonitorTests
```

## Non-functional requirements (NFR)

- **NFR-1 Platform.** macOS 13.0 (Ventura) minimum deployment target.
- **NFR-2 Privacy first.** Clipboard content never leaves the machine. No network calls,
  analytics, or telemetry. Content marked concealed/transient is never stored or persisted.
- **NFR-3 Persistence.** History survives app quit/relaunch and machine restart, stored
  locally at `~/Library/Application Support/pasta/history.json`.
- **NFR-4 Responsiveness.** Polling and UI work must not block the main thread; the
  history window opens in well under a second for a full (capped) history.
- **NFR-5 Footprint.** Single third-party dependency
  ([KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)); everything
  else uses system frameworks.
- **NFR-6 Testability.** All engine logic except the thin `SystemPasteboard` adapter is
  reachable in unit tests via protocol fakes. (Tests still link AppKit, so they run on
  macOS only — not on Linux.)
- **NFR-7 No Dock presence.** The app runs as an agent (`LSUIElement`), surfacing only
  in the menu bar.
- **NFR-8 Privacy of distribution.** Repository is private; no LICENSE file is shipped
  for MVP.

## EARS format

Acceptance criteria use Easy Approach to Requirements Syntax:

- **Ubiquitous:** `THE SYSTEM SHALL <response>.`
- **Event-driven:** `WHEN <trigger>, THE SYSTEM SHALL <response>.`
- **State-driven:** `WHILE <state>, THE SYSTEM SHALL <response>.`
- **Conditional:** `IF <condition>, THEN THE SYSTEM SHALL <response>.`

Each criterion is numbered `<FEATURE>-AC-<n>` (e.g. `02-AC-1`) so tasks and tests can
reference it.

## Build & verify (on a Mac)

```
brew install xcodegen     # one-time
make gen                  # xcodegen generate -> pasta.xcodeproj (gitignored)
make build                # xcodebuild -scheme PastaApp build
make test                 # engine unit tests
make run                  # launch the .app
```
