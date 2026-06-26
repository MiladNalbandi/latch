# 06 — Menu Bar — Design

## Files

```
Sources/LatchApp/AppDelegate.swift
Sources/LatchApp/StatusItemController.swift
```

## AppDelegate (composition root)

```swift
import AppKit
import LatchEngine

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var prefs: Preferences!
    private var pasteboard: SystemPasteboard!
    private var persistence: JSONHistoryPersistence!
    private var store: HistoryStore!
    private var monitor: ClipboardMonitor!
    private var statusItemController: StatusItemController!
    private var hotkeyManager: HotkeyManager!          // feature 07
    private var windowController: HistoryWindowController! // feature 08
    private var loginItemManager: LoginItemManager!    // feature 10

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)          // 06-AC-6

        prefs = Preferences()
        pasteboard = SystemPasteboard()
        persistence = JSONHistoryPersistence()
        store = HistoryStore(persistence: persistence, cap: prefs.historyCap)
        store.load()                                   // 06-AC-7

        monitor = ClipboardMonitor(pasteboard: pasteboard,
                                   filter: PrivacyFilter(),
                                   interval: prefs.pollInterval)
        monitor.onCapture = { [weak self] item in self?.store.add(item) }  // 06-AC-7
        monitor.start()

        windowController = HistoryWindowController(store: store,
                                                   pasteboard: pasteboard,
                                                   matcher: FuzzyMatcher())  // feature 08
        statusItemController = StatusItemController(
            onShow:  { [weak self] in self?.windowController.toggle() },     // 06-AC-3
            onPrefs: { [weak self] in self?.showPreferences() },             // 06-AC-4
            onQuit:  { NSApp.terminate(nil) })                              // 06-AC-5

        hotkeyManager = HotkeyManager { [weak self] in self?.windowController.toggle() } // feature 07
        loginItemManager = LoginItemManager()          // feature 10
    }

    func applicationWillTerminate(_ notification: Notification) {
        persistence.flush()                            // 06-AC-8
    }

    private func showPreferences() { /* feature 09: open PreferencesWindowController */ }
}
```

> The `AppDelegate` is the single composition root. Forward references to features 07–10
> are stubbed here and fleshed out in their specs; this spec's responsibility is the wiring
> contract and lifecycle.

## StatusItemController

```swift
final class StatusItemController {
    private let statusItem: NSStatusItem
    init(onShow: @escaping () -> Void,
         onPrefs: @escaping () -> Void,
         onQuit: @escaping () -> Void) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "doc.on.clipboard",
                                           accessibilityDescription: "Latch")   // 06-AC-1
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Latch", action: ..., keyEquivalent: "")   // 06-AC-2/3
        menu.addItem(.separator())
        menu.addItem(withTitle: "Preferences…", action: ..., keyEquivalent: ",")// 06-AC-2/4
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Latch", action: ..., keyEquivalent: "q")  // 06-AC-2/5
        statusItem.menu = menu
    }
}
```

Actions are delivered to the closures via a small target wrapper (or `@objc` selectors on
the controller that call the stored closures).

## Edge cases

- If the status button image fails to load (older system), fall back to a title "Latch".
- Quit flushes persistence first (06-AC-5 / 06-AC-8) so no recent captures are lost.
- `.accessory` policy means the app has no main menu; all interaction is via the status
  menu, the hotkey, and the windows.
