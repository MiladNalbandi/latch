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

import XCTest
@testable import LatchEngine

final class PreferencesTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        let suite = "latch.tests." + UUID().uuidString
        return UserDefaults(suiteName: suite)!
    }

    func testDefaultsWhenUnset() {
        let p = Preferences(defaults: makeDefaults())
        XCTAssertEqual(p.historyCap, Preferences.defaultCap)
        XCTAssertEqual(p.pollInterval, Preferences.defaultInterval, accuracy: 0.0001)
        XCTAssertFalse(p.soundOnCopy)
        XCTAssertTrue(p.showCountInMenuBar)
        XCTAssertTrue(p.ignorePasswords)
        XCTAssertEqual(p.accentKey, Preferences.defaultAccentKey)
    }

    func testCapClamps() {
        let p = Preferences(defaults: makeDefaults())
        p.historyCap = 99999
        XCTAssertEqual(p.historyCap, Preferences.capRange.upperBound)
        p.historyCap = 1
        XCTAssertEqual(p.historyCap, Preferences.capRange.lowerBound)
    }

    func testIntervalClamps() {
        let p = Preferences(defaults: makeDefaults())
        p.pollInterval = 10
        XCTAssertEqual(p.pollInterval, Preferences.intervalRange.upperBound, accuracy: 0.0001)
        p.pollInterval = 0.01
        XCTAssertEqual(p.pollInterval, Preferences.intervalRange.lowerBound, accuracy: 0.0001)
    }

    func testBoolRoundTrip() {
        let defaults = makeDefaults()
        let p = Preferences(defaults: defaults)
        p.soundOnCopy = true
        p.incognito = true
        let p2 = Preferences(defaults: defaults)
        XCTAssertTrue(p2.soundOnCopy)
        XCTAssertTrue(p2.incognito)
    }
}
