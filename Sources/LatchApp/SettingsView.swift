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

import SwiftUI
import KeyboardShortcuts
import LatchEngine

/// Tabbed settings (General / Privacy / Sync-disabled). See specs/09-preferences and
/// design/ui_kits/app/LatchSettings.jsx.
struct SettingsView: View {
    @ObservedObject var prefs: Preferences
    let loginItem: LoginItemManager
    var onClearAll: () -> Void

    enum Tab: String, CaseIterable, Identifiable {
        case general = "General", privacy = "Privacy", sync = "Sync"
        var id: String { rawValue }
        var symbol: String {
            switch self { case .general: return "gearshape"; case .privacy: return "lock.shield"; case .sync: return "sparkles" }
        }
    }
    @State private var tab: Tab = .general
    @State private var launchAtLogin: Bool = false
    @State private var axTrusted: Bool = AutoPaster.isTrusted

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider().overlay(Palette.line)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch tab {
                    case .general: general
                    case .privacy: privacy
                    case .sync: sync
                    }
                }
                .padding(20)
            }
        }
        .frame(width: 460, height: 520)
        .background(Palette.paper50)
        .onAppear {
            launchAtLogin = loginItem.isEnabled
            axTrusted = AutoPaster.isTrusted
        }
    }

    // MARK: Tabs

    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(Tab.allCases) { t in
                let on = tab == t
                Button { if t != .sync { tab = t } } label: {
                    HStack(spacing: 6) {
                        Image(systemName: t.symbol)
                        Text(t.rawValue)
                        if t == .sync { PBadge(text: "Soon", tone: .neutral) }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(t == .sync ? Palette.textFaint : (on ? Palette.primary : Palette.textBody))
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(on ? Palette.paper0 : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(t == .sync)
            }
            Spacer()
        }
        .padding(12)
    }

    // MARK: General

    private var general: some View {
        VStack(alignment: .leading, spacing: 20) {
            section("Appearance") {
                row("Accent color", "Latch follows your macOS accent color and appearance.") {
                    HStack(spacing: 8) {
                        Circle().fill(Palette.primary).frame(width: 20, height: 20)
                            .overlay(Circle().strokeBorder(Palette.line))
                        Text("System").font(.system(size: 13, weight: .medium)).foregroundColor(Palette.textMuted)
                    }
                }
            }
            section("Startup") {
                toggleRow("Launch Latch at login", "Keep your history a keystroke away.", $launchAtLogin) { on in
                    _ = loginItem.setEnabled(on)
                    launchAtLogin = loginItem.isEnabled
                }
                toggleRow("Play a sound on copy", "A soft tick when something's captured.", bind(\.soundOnCopy))
                toggleRow("Show item count in menu bar", nil, bind(\.showCountInMenuBar))
            }
            section("Pasting") {
                toggleRow("Paste directly into the app",
                          "After you pick a clip, Latch types ⌘V for you. Needs Accessibility.",
                          bind(\.autoPaste)) { on in
                    // Ask once when enabling. If declined, we don't nag — auto-paste simply
                    // stays off and Latch falls back to copy-only.
                    if on, !AutoPaster.isTrusted { AutoPaster.requestAccess() }
                    axTrusted = AutoPaster.isTrusted
                }
                if prefs.autoPaste, !axTrusted {
                    row("Accessibility not granted",
                        "Latch will just copy the clip — press ⌘V to paste yourself. Grant access anytime to enable direct paste.") {
                        PButton(title: "Open Settings…", variant: .secondary, systemImage: "arrow.up.forward.app") {
                            AutoPaster.openAccessibilitySettings()
                        }
                    }
                }
            }
            section("Shortcuts") {
                row("Open clipboard history", "The one you'll use a hundred times a day.") {
                    KeyboardShortcuts.Recorder(for: .toggleWindow)
                }
                row("Quick-paste recent", "Copy the last clip without opening Latch.") {
                    KeyboardShortcuts.Recorder(for: .quickPaste)
                }
            }
        }
    }

    // MARK: Privacy

    private var privacy: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill").foregroundColor(Palette.secure)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your clipboard never leaves this Mac.").font(.system(size: 13, weight: .semibold))
                    Text("History is stored encrypted on-device. No account required.")
                        .font(.system(size: 12)).foregroundColor(Palette.textMuted)
                }
            }
            .padding(12)
            .background(Palette.secureTint.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

            section("What Latch captures") {
                toggleRow("Ignore passwords", "Skip anything copied from a password manager.", bind(\.ignorePasswords))
                toggleRow("Clear history when Mac locks", nil, bind(\.clearOnLock))
                toggleRow("Pause capture (incognito)", "Temporarily stop recording new copies.", bind(\.incognito))
            }
            section("History") {
                row("Keep the last", "Older clips fall off automatically (pinned stay).") {
                    HStack(spacing: 8) {
                        Stepper("", value: capBinding, in: Preferences.capRange, step: 10).labelsHidden()
                        PBadge(text: "\(prefs.historyCap) items", tone: .primary)
                    }
                }
            }
            HStack {
                Spacer()
                PButton(title: "Clear all history…", variant: .danger, systemImage: "trash", action: onClearAll)
            }
        }
    }

    // MARK: Sync (disabled placeholder)

    private var sync: some View {
        VStack(alignment: .leading, spacing: 12) {
            PBadge(text: "Coming soon", tone: .neutral)
            Text("iCloud sync isn't part of v0.1. Your history stays on this Mac.")
                .font(.system(size: 13)).foregroundColor(Palette.textMuted)
        }
    }

    // MARK: Building blocks

    private func section<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).eyebrowStyle()
            PCard { VStack(spacing: 0) { content() } }
        }
    }

    private func row<C: View>(_ title: String, _ desc: String?, @ViewBuilder _ control: () -> C) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(Palette.textStrong)
                if let d = desc { Text(d).font(.system(size: 12)).foregroundColor(Palette.textMuted) }
            }
            Spacer()
            control()
        }
        .padding(.horizontal, 14).padding(.vertical, 11)
    }

    private func toggleRow(_ title: String, _ desc: String?, _ binding: Binding<Bool>, onChange: ((Bool) -> Void)? = nil) -> some View {
        row(title, desc) {
            PSwitch(isOn: Binding(get: { binding.wrappedValue }, set: { binding.wrappedValue = $0; onChange?($0) }))
        }
    }

    // MARK: Bindings to Preferences

    private func bind(_ key: ReferenceWritableKeyPath<Preferences, Bool>) -> Binding<Bool> {
        Binding(get: { prefs[keyPath: key] }, set: { prefs[keyPath: key] = $0 })
    }
    private var capBinding: Binding<Int> {
        Binding(get: { prefs.historyCap }, set: { prefs.historyCap = $0 })
    }
}
