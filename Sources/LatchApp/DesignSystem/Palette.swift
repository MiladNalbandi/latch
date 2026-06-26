import SwiftUI

extension Color {
    /// 0xRRGGBB convenience.
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

/// Holds the user-chosen accent color, recoloring `Palette.primary` live (feature 09 + 11).
final class AccentStore: ObservableObject {
    static let shared = AccentStore()

    /// System-accent-style swatches, Latch green default.
    struct Accent: Identifiable, Equatable {
        let id: String
        let name: String
        let color: Color
        let on: Color
    }

    static let accents: [Accent] = [
        Accent(id: "latch", name: "Latch", color: Color(hex: 0x12A877), on: .white),
        Accent(id: "blue", name: "Blue", color: Color(hex: 0x007AFF), on: .white),
        Accent(id: "purple", name: "Purple", color: Color(hex: 0xA64DD6), on: .white),
        Accent(id: "pink", name: "Pink", color: Color(hex: 0xF74F9E), on: .white),
        Accent(id: "red", name: "Red", color: Color(hex: 0xFF5257), on: .white),
        Accent(id: "orange", name: "Orange", color: Color(hex: 0xF7821B), on: .white),
        Accent(id: "yellow", name: "Yellow", color: Color(hex: 0xFFC402), on: Color(hex: 0x3A2C00)),
        Accent(id: "graphite", name: "Graphite", color: Color(hex: 0x8A8A8E), on: .white),
    ]

    @Published var key: String = "latch"

    var current: Accent { AccentStore.accents.first { $0.id == key } ?? AccentStore.accents[0] }
    var color: Color { current.color }
    var onColor: Color { current.on }

    func set(_ key: String) { self.key = key }
}

/// Latch color tokens (from design/tokens/colors.css).
enum Palette {
    // Paper (warm canvas)
    static let paper0 = Color(hex: 0xFFFFFF)
    static let paper50 = Color(hex: 0xFBFAF6)
    static let paper100 = Color(hex: 0xF4F2EC)
    static let paper200 = Color(hex: 0xEBE8DF)
    static let line = Color(hex: 0xE4E1D8)
    static let lineStrong = Color(hex: 0xD4D0C4)

    // Ink ramp (cool near-black)
    static let ink900 = Color(hex: 0x11141A)
    static let ink800 = Color(hex: 0x1B1F27)
    static let ink700 = Color(hex: 0x2B313B)
    static let ink500 = Color(hex: 0x5A626E)
    static let ink400 = Color(hex: 0x7A828D)
    static let ink200 = Color(hex: 0xC3C8CF)

    // Latch green
    static let green700 = Color(hex: 0x0A6A4A)
    static let green600 = Color(hex: 0x0E8C63)
    static let green500 = Color(hex: 0x12A877)
    static let green300 = Color(hex: 0x7ADCBB)
    static let green100 = Color(hex: 0xD6F2E6)
    static let green50 = Color(hex: 0xECFAF3)

    // Accent / secure / danger
    static let amber500 = Color(hex: 0xF2A52C)
    static let blue600 = Color(hex: 0x1F55C9)
    static let blue500 = Color(hex: 0x2F6FED)
    static let blue100 = Color(hex: 0xDBE7FC)
    static let red500 = Color(hex: 0xE5484D)
    static let red600 = Color(hex: 0xC93B3F)
    static let red100 = Color(hex: 0xFBDCDD)

    // Dark "ink" surfaces (footer, keycaps)
    static let inkSurface = Color(hex: 0x181C23)
    static let inkSurface2 = Color(hex: 0x20252E)
    static let textOnInk = Color(hex: 0xEEF0F2)

    // Semantic (primary follows the live accent)
    static var primary: Color { AccentStore.shared.color }
    static var onPrimary: Color { AccentStore.shared.onColor }
    static let primaryHover = green600
    static let primaryPress = green700
    static let primaryTint = green100
    static let primaryTintSoft = green50

    static let textStrong = ink900
    static let textBody = ink700
    static let textMuted = ink500
    static let textFaint = ink400

    static let secure = blue500
    static let secureTint = blue100
    static let danger = red500
    static let accent = amber500
}
