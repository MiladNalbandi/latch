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

final class CryptoBoxTests: XCTestCase {
    /// Use an in-memory key store so tests don't depend on a login Keychain (CI-safe).
    private func uniqueBox() -> CryptoBox {
        CryptoBox(keyStore: InMemoryKeyStore())
    }

    func testSealOpenRoundTrip() throws {
        let box = uniqueBox()
        let plaintext = Data("the quick brown fox".utf8)
        let sealed = try box.seal(plaintext)
        XCTAssertNotEqual(sealed, plaintext)               // not plaintext on the wire
        let opened = try box.open(sealed)
        XCTAssertEqual(opened, plaintext)
    }

    func testOpenGarbageThrows() {
        let box = uniqueBox()
        XCTAssertThrowsError(try box.open(Data([0x00, 0x01, 0x02])))
    }
}
