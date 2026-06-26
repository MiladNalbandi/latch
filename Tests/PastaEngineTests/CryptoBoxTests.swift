import XCTest
@testable import PastaEngine

final class CryptoBoxTests: XCTestCase {
    /// Use a unique service per run so we don't collide with a real key in the Keychain.
    private func uniqueBox() -> CryptoBox {
        CryptoBox(service: "com.pasta.test." + UUID().uuidString, account: "test")
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
