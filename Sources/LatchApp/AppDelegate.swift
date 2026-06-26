import AppKit
import Combine
import LatchEngine

/// Composition root: constructs and wires the engine + UI, owns lifecycle. See specs/06.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var prefs: Preferences!
    private var pasteboard: SystemPasteboard!
    private var persistence: EncryptedJSONPersistence!
    private var store: HistoryStore!
    private var monitor: ClipboardMonitor!

    private var statusItem: StatusItemController!
    private var panel: HistoryPanelController!
    private var settings: SettingsWindowController!
    private var hotkeys: HotkeyManager!
    private var loginItem: LoginItemManager!
    private var lockMonitor: LockMonitor!

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Engine
        prefs = Preferences()
        AccentStore.shared.set(prefs.accentKey)

        pasteboard = SystemPasteboard()
        persistence = EncryptedJSONPersistence()
        store = HistoryStore(persistence: persistence, cap: prefs.historyCap)
        // Load history off the main thread: decryption reads the AES key from the Keychain,
        // which can block (or prompt) — never let that freeze menu-bar/hotkey setup below.
        store.loadAsync()

        monitor = ClipboardMonitor(
            pasteboard: pasteboard,
            classifier: ClipClassifier(),
            filter: PrivacyFilter(ignorePasswords: prefs.ignorePasswords),
            source: pasteboard,
            interval: prefs.pollInterval
        )
        monitor.isPaused = prefs.incognito
        monitor.onCapture = { [weak self] item in
            guard let self else { return }
            self.store.add(item)
            if self.prefs.soundOnCopy { NSSound(named: "Tink")?.play() }
        }
        monitor.start()

        // UI
        loginItem = LoginItemManager()
        settings = SettingsWindowController(
            prefs: prefs, loginItem: loginItem,
            onClearAll: { [weak self] in self?.confirmClearAll() }
        )
        panel = HistoryPanelController(
            store: store, matcher: FuzzyMatcher(), pasteboard: pasteboard,
            onOpenSettings: { [weak self] in self?.settings.show() },
            onCopySound: { [weak self] in if self?.prefs.soundOnCopy == true { NSSound(named: "Pop")?.play() } }
        )
        statusItem = StatusItemController(
            onShow: { [weak self] in self?.panel.toggle() },
            onPrefs: { [weak self] in self?.settings.show() },
            onToggleIncognito: { [weak self] in self?.toggleIncognito() },
            onQuit: { NSApp.terminate(nil) }
        )
        hotkeys = HotkeyManager(
            onToggle: { [weak self] in self?.panel.toggle() },
            onQuickPaste: { [weak self] in self?.quickPaste() }
        )
        lockMonitor = LockMonitor(onLock: { [weak self] in
            guard let self, self.prefs.clearOnLock else { return }
            self.store.clear()
        })

        // Initial menu-bar state + live observers
        statusItem.update(showCount: prefs.showCountInMenuBar)
        statusItem.update(incognito: prefs.incognito)
        observeStore()
        observePrefs()
    }

    func applicationWillTerminate(_: Notification) {
        store.flush()
    }

    // MARK: - Observers

    private func observeStore() {
        store.$items
            .receive(on: RunLoop.main)
            .sink { [weak self] items in self?.statusItem.update(count: items.count) }
            .store(in: &cancellables)
    }

    private func observePrefs() {
        prefs.objectWillChange
            .receive(on: RunLoop.main)   // run after the value has changed
            .sink { [weak self] in self?.applyPrefs() }
            .store(in: &cancellables)
    }

    private func applyPrefs() {
        store.setCap(prefs.historyCap)
        monitor.setInterval(prefs.pollInterval)
        monitor.filter.ignorePasswords = prefs.ignorePasswords
        monitor.isPaused = prefs.incognito
        statusItem.update(showCount: prefs.showCountInMenuBar)
        statusItem.update(incognito: prefs.incognito)
        AccentStore.shared.set(prefs.accentKey)
    }

    // MARK: - Actions

    private func toggleIncognito() {
        prefs.incognito.toggle()   // observePrefs() applies + updates menu bar
    }

    private func quickPaste() {
        guard let latest = store.items.first else { return }
        pasteboard.write(latest)
        if prefs.soundOnCopy { NSSound(named: "Pop")?.play() }
    }

    private func confirmClearAll() {
        let alert = NSAlert()
        alert.messageText = "Clear all clipboard history?"
        alert.informativeText = "This permanently removes every clip, including pinned ones."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear all")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            store.clear()
        }
    }
}
