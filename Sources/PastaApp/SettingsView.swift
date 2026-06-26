import SwiftUI
import KeyboardShortcuts
import PastaEngine

/// Tabbed settings (General / Privacy / Sync-disabled). See specs/09-preferences and
/// design/ui_kits/app/LatchSettings.jsx.
struct SettingsView: View {
    @ObservedObject var prefs: Preferences
    @ObservedObject var accent = AccentStore.shared
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
        .onAppear { launchAtLogin = loginItem.isEnabled }
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
                    .foregroundColor(t == .sync ? Palette.textFaint : (on ? Palette.primaryPress : Palette.textBody))
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(on ? Color.white : .clear)
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
                row("Accent color", "Used for selection, controls, and highlights.") {
                    HStack(spacing: 8) {
                        ForEach(AccentStore.accents) { a in
                            Circle().fill(a.color)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().strokeBorder(Color.black.opacity(0.1)))
                                .overlay(
                                    Image(systemName: "checkmark").font(.system(size: 10, weight: .bold))
                                        .foregroundColor(a.on).opacity(a.id == accent.key ? 1 : 0)
                                )
                                .onTapGesture { accent.set(a.id); prefs.accentKey = a.id }
                        }
                    }
                }
            }
            section("Startup") {
                toggleRow("Launch pasta at login", "Keep your history a keystroke away.", $launchAtLogin) { on in
                    _ = loginItem.setEnabled(on)
                    launchAtLogin = loginItem.isEnabled
                }
                toggleRow("Play a sound on copy", "A soft tick when something's captured.", bind(\.soundOnCopy))
                toggleRow("Show item count in menu bar", nil, bind(\.showCountInMenuBar))
            }
            section("Shortcuts") {
                row("Open clipboard history", "The one you'll use a hundred times a day.") {
                    KeyboardShortcuts.Recorder(for: .toggleWindow)
                }
                row("Quick-paste recent", "Copy the last clip without opening pasta.") {
                    KeyboardShortcuts.Recorder(for: .quickPaste)
                }
            }
        }
    }

    // MARK: Privacy

    private var privacy: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill").foregroundColor(Palette.blue600)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your clipboard never leaves this Mac.").font(.system(size: 13, weight: .semibold))
                    Text("History is stored encrypted on-device. No account required.")
                        .font(.system(size: 12)).foregroundColor(Palette.textMuted)
                }
            }
            .padding(12)
            .background(Palette.secureTint.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

            section("What pasta captures") {
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
