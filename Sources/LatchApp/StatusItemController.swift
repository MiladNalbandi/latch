// Latch — the friendly, private clipboard for macOS.
// Copyright (C) 2026 Milad Nalbandi
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import AppKit

/// The menu-bar presence: icon (+ optional count), and a menu. See specs/06-menu-bar.
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let onShow: () -> Void
    private let onPrefs: () -> Void
    private let onToggleIncognito: () -> Void
    private let onWelcome: () -> Void
    private let onCheckUpdates: () -> Void
    private let onQuit: () -> Void

    private var showCount = true
    private var count = 0
    private var incognito = false

    private let pauseItem = NSMenuItem(title: "Pause capturing (incognito)", action: nil, keyEquivalent: "")
    private let updateItem = NSMenuItem(title: "Check for Updates…", action: nil, keyEquivalent: "")

    init(onShow: @escaping () -> Void,
         onPrefs: @escaping () -> Void,
         onToggleIncognito: @escaping () -> Void,
         onWelcome: @escaping () -> Void,
         onCheckUpdates: @escaping () -> Void,
         onQuit: @escaping () -> Void) {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.onShow = onShow
        self.onPrefs = onPrefs
        self.onToggleIncognito = onToggleIncognito
        self.onWelcome = onWelcome
        self.onCheckUpdates = onCheckUpdates
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

    /// Reflect an available update in the menu (title becomes a download prompt).
    func update(updateAvailable version: String?) {
        updateItem.title = version.map { "Download Latch \($0)…" } ?? "Check for Updates…"
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
        menu.addItem(item("Welcome to Latch", #selector(welcomeTapped), key: ""))
        updateItem.target = self
        updateItem.action = #selector(checkUpdatesTapped)
        menu.addItem(updateItem)
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
    @objc private func welcomeTapped() { onWelcome() }
    @objc private func checkUpdatesTapped() { onCheckUpdates() }
    @objc private func quitTapped() { onQuit() }
}
