import AppKit
import KeyboardShortcuts
import LatchEngine
import SwiftUI

/// First-run welcome / quick tutorial. Introduces Latch and its keyboard flow.
/// Shown once on first launch and re-openable from the menu bar.
struct WelcomeView: View {
    var onStart: () -> Void
    var onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            header
            PCard { VStack(spacing: 0) { ForEach(Array(tips.enumerated()), id: \.offset) { _, tip in tipRow(tip) } } }
            secureNote
            buttons
        }
        .padding(24)
        .frame(width: 460)
        .background(Palette.paper50)
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 72, height: 72)
            Text("Welcome to Latch")
                .font(Typo.display(26))
                .foregroundColor(Palette.textStrong)
            Text("The friendly, private clipboard for macOS.")
                .font(Typo.body)
                .foregroundColor(Palette.textMuted)
        }
        .padding(.top, 4)
    }

    // MARK: Tips cheat-sheet

    private struct Tip { let keys: [String]; let text: String }

    private var tips: [Tip] {
        [
            Tip(keys: [openShortcut ?? "⌘⇧V"], text: "Open your clipboard history anywhere"),
            Tip(keys: ["type"], text: "Just start typing to search instantly"),
            Tip(keys: ["tab"], text: "Switch filters — All, Pinned, Links, Text…"),
            Tip(keys: ["enter"], text: "Paste the selected clip back"),
            Tip(keys: ["esc"], text: "Close the panel (or click outside)"),
        ]
    }

    private func tipRow(_ tip: Tip) -> some View {
        HStack(spacing: 14) {
            PKbd(keys: tip.keys, tone: .default, size: .sm)
                .frame(width: 64, alignment: .leading)
            Text(tip.text)
                .font(.system(size: 14))
                .foregroundColor(Palette.textBody)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var secureNote: some View {
        HStack(spacing: 7) {
            Image(systemName: "lock.fill").font(.system(size: 12))
            Text("Everything stays on your Mac, encrypted.").font(.system(size: 12.5, weight: .medium))
        }
        .foregroundColor(Palette.secure)
    }

    private var buttons: some View {
        HStack(spacing: 10) {
            PButton(title: "Open Settings…", variant: .secondary, systemImage: "gearshape", action: onOpenSettings)
            Spacer()
            PButton(title: "Start using Latch", variant: .primary, systemImage: "checkmark", action: onStart)
        }
    }

    /// The global open hotkey, rendered as a keycap (matches the search-field hint).
    private var openShortcut: String? {
        KeyboardShortcuts.getShortcut(for: .toggleWindow).map(String.init(describing:))
    }
}
