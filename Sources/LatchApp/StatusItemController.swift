import AppKit

/// The menu-bar presence: icon (+ optional count), and a menu. See specs/06-menu-bar.
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let onShow: () -> Void
    private let onPrefs: () -> Void
    private let onToggleIncognito: () -> Void
    private let onQuit: () -> Void

    private var showCount = true
    private var count = 0
    private var incognito = false

    private let pauseItem = NSMenuItem(title: "Pause capturing (incognito)", action: nil, keyEquivalent: "")

    init(onShow: @escaping () -> Void,
         onPrefs: @escaping () -> Void,
         onToggleIncognito: @escaping () -> Void,
         onQuit: @escaping () -> Void) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.onShow = onShow
        self.onPrefs = onPrefs
        self.onToggleIncognito = onToggleIncognito
        self.onQuit = onQuit
        super.init()
        buildMenu()
        refreshButton()
    }

    // MARK: Public updates

    func update(count: Int) { self.count = count; refreshButton() }
    func update(showCount: Bool) { self.showCount = showCount; refreshButton() }
    func update(incognito: Bool) {
        self.incognito = incognito
        pauseItem.state = incognito ? .on : .off
        refreshButton()
    }

    // MARK: Build

    private func buildMenu() {
        let menu = NSMenu()
        menu.addItem(item("Show Latch", #selector(showTapped), key: ""))
        pauseItem.target = self
        pauseItem.action = #selector(pauseTapped)
        menu.addItem(pauseItem)
        menu.addItem(.separator())
        menu.addItem(item("Preferences…", #selector(prefsTapped), key: ","))
        menu.addItem(.separator())
        menu.addItem(item("Quit Latch", #selector(quitTapped), key: "q"))
        statusItem.menu = menu
    }

    private func item(_ title: String, _ action: Selector, key: String) -> NSMenuItem {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: key)
        i.target = self
        return i
    }

    private func refreshButton() {
        guard let button = statusItem.button else { return }
        let symbol = incognito ? "eye.slash" : "doc.on.clipboard"
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Latch")
        button.imagePosition = .imageLeading
        button.title = (showCount && !incognito && count > 0) ? " \(count)" : ""
    }

    // MARK: Actions

    @objc private func showTapped() { onShow() }
    @objc private func pauseTapped() { onToggleIncognito() }
    @objc private func prefsTapped() { onPrefs() }
    @objc private func quitTapped() { onQuit() }
}
