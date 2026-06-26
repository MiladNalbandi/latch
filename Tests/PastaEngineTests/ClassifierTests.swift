import XCTest
@testable import PastaEngine

final class ClassifierTests: XCTestCase {
    let c = ClipClassifier()

    func testColor() {
        XCTAssertEqual(c.classify(text: "#12A877", types: [], source: nil), .color)
        XCTAssertEqual(c.classify(text: "#abc", types: [], source: nil), .color)
        XCTAssertEqual(c.classify(text: "rgb(18, 168, 119)", types: [], source: nil), .color)
    }

    func testLink() {
        XCTAssertEqual(c.classify(text: "https://pasta.app/x", types: [], source: nil), .link)
        XCTAssertEqual(c.classify(text: "mailto:you@pasta.app", types: [], source: nil), .link)
        XCTAssertEqual(c.classify(text: "github.com/x/y", types: [], source: nil), .link)
        XCTAssertNotEqual(c.classify(text: "hello world", types: [], source: nil), .link)
    }

    func testCode() {
        XCTAssertEqual(c.classify(text: "git rebase -i HEAD~3", types: [], source: nil), .code)
        XCTAssertEqual(c.classify(text: "let x = 1", types: [], source: "Xcode"), .code)
    }

    func testFileAndImage() {
        XCTAssertEqual(c.classify(text: nil, types: [PasteboardType.fileURL], source: nil), .file)
        XCTAssertEqual(c.classify(text: nil, types: [PasteboardType.png], source: nil), .image)
        XCTAssertEqual(c.classify(text: "", types: [PasteboardType.tiff], source: nil), .image)
    }

    func testText() {
        XCTAssertEqual(c.classify(text: "Thanks — let's talk Thursday.", types: [], source: "Mail"), .text)
    }

    func testPrecedenceColorBeatsLink() {
        // A bare hex is not a URL, but ensure color is detected before code/text.
        XCTAssertEqual(c.classify(text: "#2f6fed", types: [], source: "Xcode"), .color)
    }
}
