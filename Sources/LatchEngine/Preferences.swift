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
