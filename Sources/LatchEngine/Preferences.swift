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

import Foundation
import Combine

/// `UserDefaults`-backed settings, observable for live application. The global hotkeys are
/// owned by the KeyboardShortcuts library, not here. See specs/09-preferences.
public final class Preferences: ObservableObject {
    public static let capRange: ClosedRange<Int> = 10...1000
    public static let intervalRange: ClosedRange<Double> = 0.2...2.0
    public static let defaultCap = 200
    public static let defaultInterval = 0.5
    public static let defaultAccentKey = "latch"

    private enum Key {
        static let cap = "latch.historyCap"
        static let interval = "latch.pollInterval"
        static let soundOnCopy = "latch.soundOnCopy"
        static let showCount = "latch.showCountInMenuBar"
        static let ignorePasswords = "latch.ignorePasswords"
        static let clearOnLock = "latch.clearOnLock"
        static let incognito = "latch.incognito"
        static let accentKey = "latch.accentKey"
        static let autoPaste = "latch.autoPaste"
        static let hasSeenWelcome = "latch.hasSeenWelcome"
    }

    /// Explicit publisher — all settings are computed (no `@Published` members).
    public let objectWillChange = ObservableObjectPublisher()

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.cap: Preferences.defaultCap,
            Key.interval: Preferences.defaultInterval,
            Key.soundOnCopy: false,
            Key.showCount: true,
            Key.ignorePasswords: true,
            Key.clearOnLock: false,
            Key.incognito: false,
            Key.accentKey: Preferences.defaultAccentKey,
            Key.autoPaste: true,
            Key.hasSeenWelcome: false,
        ])
    }

    public var historyCap: Int {
        get { clamp(defaults.integer(forKey: Key.cap), Preferences.capRange, Preferences.defaultCap) }
        set { objectWillChange.send(); defaults.set(clamp(newValue, Preferences.capRange, Preferences.defaultCap), forKey: Key.cap) }
    }

    public var pollInterval: Double {
        get {
            let v = defaults.double(forKey: Key.interval)
            return Preferences.intervalRange.contains(v) ? v : Preferences.defaultInterval
        }
        set { objectWillChange.send(); defaults.set(clampDouble(newValue, Preferences.intervalRange, Preferences.defaultInterval), forKey: Key.interval) }
    }

    public var soundOnCopy: Bool {
        get { defaults.bool(forKey: Key.soundOnCopy) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.soundOnCopy) }
    }

    public var showCountInMenuBar: Bool {
        get { defaults.bool(forKey: Key.showCount) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.showCount) }
    }

    public var ignorePasswords: Bool {
        get { defaults.bool(forKey: Key.ignorePasswords) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.ignorePasswords) }
    }

    public var clearOnLock: Bool {
        get { defaults.bool(forKey: Key.clearOnLock) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.clearOnLock) }
    }

    public var incognito: Bool {
        get { defaults.bool(forKey: Key.incognito) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.incognito) }
    }

    /// Retained for persistence/back-compat; Latch now follows the macOS system accent
    /// (`Color.accentColor`) rather than a stored choice.
    public var accentKey: String {
        get { defaults.string(forKey: Key.accentKey) ?? Preferences.defaultAccentKey }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.accentKey) }
    }

    /// Paste the picked clip directly into the previous app (simulated ⌘V).
    /// Requires Accessibility permission; falls back to copy-only when not granted.
    public var autoPaste: Bool {
        get { defaults.bool(forKey: Key.autoPaste) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.autoPaste) }
    }

    /// Whether the first-run welcome screen has been shown.
    public var hasSeenWelcome: Bool {
        get { defaults.bool(forKey: Key.hasSeenWelcome) }
        set { objectWillChange.send(); defaults.set(newValue, forKey: Key.hasSeenWelcome) }
    }

    // MARK: - Helpers

    private func clamp(_ v: Int, _ range: ClosedRange<Int>, _ fallback: Int) -> Int {
        guard v != 0 else { return fallback }
        return min(max(v, range.lowerBound), range.upperBound)
    }

    private func clampDouble(_ v: Double, _ range: ClosedRange<Double>, _ fallback: Double) -> Double {
        guard v != 0 else { return fallback }
        return min(max(v, range.lowerBound), range.upperBound)
    }
}
