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

final class PersistenceTests: XCTestCase {
    private var tmpDir: URL!
    private var fileURL: URL!

    override func setUpWithError() throws {
        tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("Latch-tests-" + UUID().uuidString, isDirectory: true)
        fileURL = tmpDir.appendingPathComponent("history.dat")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tmpDir)
    }

    /// A shared in-memory key store so save+load within a test use the same key (CI-safe).
    private let keyStore = InMemoryKeyStore()

    private func makePersistence() -> EncryptedJSONPersistence {
        EncryptedJSONPersistence(
            fileURL: fileURL,
            crypto: CryptoBox(keyStore: keyStore),
            debounceInterval: 0.05
        )
    }

    func testRoundTripEncrypted() throws {
        let p = makePersistence()
        let items = [ClipItem.text("alpha"), ClipItem.text("beta")]
        p.save(items)
        p.flush()

        // On-disk bytes must not contain the plaintext.
        let raw = try Data(contentsOf: fileURL)
        XCTAssertFalse(String(data: raw, encoding: .utf8)?.contains("alpha") ?? false)

        let loaded = p.load()
        XCTAssertEqual(loaded.map(\.preview), ["alpha", "beta"])
    }

    func testLoadMissingFileReturnsEmpty() {
        let p = makePersistence()
        XCTAssertTrue(p.load().isEmpty)
    }

    func testLoadCorruptReturnsEmpty() throws {
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        try Data("not encrypted json".utf8).write(to: fileURL)
        let p = makePersistence()
        XCTAssertTrue(p.load().isEmpty)   // no crash, empty
    }

    func testFlushWritesPendingImmediately() {
        let p = makePersistence()
        p.save([ClipItem.text("x")])
        p.flush()
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }
}
