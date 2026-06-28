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

/// Keycap row — the Latch signature object. Renders "cmd+shift+V" or ["up","down"] as
/// pressable caps. (design/components/core/Kbd.jsx)
struct PKbd: View {
    enum Tone { case `default`, go, ink }
    enum Size { case sm, md, lg }

    let keys: [String]
    var tone: Tone = .default
    var size: Size = .md

    init(_ keys: String, tone: Tone = .default, size: Size = .md) {
        self.keys = keys.split(separator: "+").map { String($0).trimmingCharacters(in: .whitespaces) }
        self.tone = tone
        self.size = size
    }

    init(keys: [String], tone: Tone = .default, size: Size = .md) {
        self.keys = keys
        self.tone = tone
        self.size = size
    }

    static let glyphs: [String: String] = [
        "cmd": "⌘", "command": "⌘", "shift": "⇧", "opt": "⌥", "option": "⌥", "alt": "⌥",
        "ctrl": "⌃", "control": "⌃", "enter": "↩", "return": "↩", "esc": "⎋", "escape": "⎋",
        "space": "Space", "tab": "⇥", "del": "⌫", "backspace": "⌫",
        "up": "↑", "down": "↓", "left": "←", "right": "→",
    ]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(keys.enumerated()), id: \.offset) { idx, key in
                if idx > 0 {
                    Text("+").font(Typo.mono(fontSize * 0.85)).foregroundColor(Palette.textFaint)
                }
                cap(for: key)
            }
        }
    }

    private func cap(for key: String) -> some View {
        Text(PKbd.glyphs[key.lowercased()] ?? key)
            .font(Typo.mono(fontSize, .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, padX)
            .padding(.vertical, padY)
            .frame(minWidth: minWidth)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: Radius.keycap, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.keycap, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            )
            .overlay(alignment: .bottom) {
                // 2px pressable bottom edge.
                Rectangle().fill(border).frame(height: 1.5)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.keycap, style: .continuous))
            }
    }

    // MARK: tones / sizes

    private var fg: Color {
        switch tone {
        case .default: return Palette.ink800
        case .go: return Palette.onPrimary
        case .ink: return Palette.textOnInk
        }
    }
    private var bg: Color {
        switch tone {
        case .default: return Palette.paper0
        case .go: return Palette.primary
        case .ink: return Palette.inkSurface2
        }
    }
    private var border: Color {
        switch tone {
        case .default: return Palette.lineStrong
        case .go: return Palette.primaryPress
        case .ink: return .black
        }
    }
    private var fontSize: CGFloat { size == .sm ? 11 : (size == .lg ? 16 : 13) }
    private var padX: CGFloat { size == .sm ? 5 : (size == .lg ? 11 : 8) }
    private var padY: CGFloat { size == .sm ? 3 : (size == .lg ? 8 : 5) }
    private var minWidth: CGFloat { size == .sm ? 14 : (size == .lg ? 22 : 18) }
}
