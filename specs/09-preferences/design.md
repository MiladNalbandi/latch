# 09 — Settings — Design

> Reworked for the Latch tabbed settings. Reference:
> `/design/ui_kits/app/LatchSettings.jsx`.

## v0.1 Latch files

```
Sources/LatchEngine/Preferences.swift              # UserDefaults config (engine)
Sources/LatchApp/SettingsWindowController.swift    # single titled window host
Sources/LatchApp/SettingsView.swift                # tabbed: General / Privacy / Sync(disabled)
```

`Preferences` (engine) gains, beyond `historyCap`/`pollInterval`:
`soundOnCopy: Bool` (def false), `showCountInMenuBar: Bool` (def true),
`ignorePasswords: Bool` (def true), `clearOnLock: Bool` (def false),
`incognito: Bool` (def false), `accentKey: String` (def "latch"). All `@Published`,
`UserDefaults`-backed, clamped where numeric.

`SettingsView` renders `Section`/`Row` like the JSX, using `PSwitch`, `PButton`,
`PBadge`, `PKbd`, and `KeyboardShortcuts.Recorder`. Accent picker writes
`AccentStore.shared` (feature 11) + `prefs.accentKey`. Sync tab shows a disabled card with a
"Coming soon" badge. Live application is wired in `AppDelegate` via Combine sinks:
`historyCap→store.setCap`, `pollInterval→monitor.setInterval`, `incognito→monitor.isPaused +
menu bar`, `showCountInMenuBar→status item`, `accentKey→AccentStore`.

## Original single-pane notes (superseded)

## Files

```
Sources/LatchEngine/Preferences.swift            # UserDefaults-backed config (engine)
Sources/LatchApp/PreferencesView.swift           # SwiftUI form
Sources/LatchApp/PreferencesWindowController.swift # hosts the form in a normal window
```

## Preferences (engine)

```swift
public final class Preferences: ObservableObject {
    private let defaults: UserDefaults
    public init(defaults: UserDefaults = .standard)

    public static let capRange: ClosedRange<Int> = 10...1000
    public static let intervalRange: ClosedRange<Double> = 0.2...2.0
    public static let defaultCap = 200
    public static let defaultInterval = 0.5

    @Published public var historyCap: Int        // get/set -> defaults["historyCap"], clamped (09-AC-2/9)
    @Published public var pollInterval: Double    // get/set -> defaults["pollInterval"], clamped (09-AC-4/9)
}
```

- Keys: `"latch.historyCap"`, `"latch.pollInterval"`. Missing → defaults (09-AC-8).
- Setters clamp to the allowed range (09-AC-9).
- Hotkey is owned by `KeyboardShortcuts` (its own UserDefaults storage), not here.

## Live application

The `AppDelegate` (composition root) observes `Preferences` changes and forwards them:

```swift
prefs.$historyCap.sink { [weak self] cap in self?.store.setCap(cap) }       // 09-AC-3
prefs.$pollInterval.sink { [weak self] iv in self?.monitor.setInterval(iv) } // 09-AC-5
```

(Or the `PreferencesView` actions call `store.setCap` / `monitor.setInterval` directly via
closures passed in.) Either way the change is immediate and persisted.

## PreferencesView (SwiftUI)

```swift
struct PreferencesView: View {
    @ObservedObject var prefs: Preferences
    let loginItem: LoginItemManager           // feature 10

    var body: some View {
        Form {
            Stepper("History size: \(prefs.historyCap)",
                    value: $prefs.historyCap,
                    in: Preferences.capRange)                      // 09-AC-2/3
            Slider(value: $prefs.pollInterval,
                   in: Preferences.intervalRange, step: 0.1) {
                Text("Poll interval: \(prefs.pollInterval, specifier: "%.1f")s")
            }                                                      // 09-AC-4/5
            KeyboardShortcuts.Recorder("Summon hotkey:",
                                       name: .toggleWindow)        // 09-AC-6
            Toggle("Launch at login", isOn: loginItemBinding)      // 09-AC-7
        }
        .padding(20)
        .frame(width: 360)
    }
}
```

- `loginItemBinding` reads `loginItem.isEnabled` and on set calls
  `loginItem.setEnabled(_:)` (feature 10).

## PreferencesWindowController

A standard titled window (not the floating panel) hosting `PreferencesView` via
`NSHostingController`. Opened by the status-menu action (feature 06). Single instance —
re-opening brings the existing window to front.

## Edge cases

- Out-of-range typed values clamped to bounds (09-AC-9); Stepper/Slider already constrain.
- Lowering history size evicts immediately (delegated to `HistoryStore.setCap`, 03-AC-5).
- Changing interval mustn't cause a spurious capture (delegated to
  `ClipboardMonitor.setInterval`, 01-AC-9).
