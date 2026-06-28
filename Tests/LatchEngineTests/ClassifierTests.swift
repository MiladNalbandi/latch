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

final class ClassifierTests: XCTestCase {
    let c = ClipClassifier()

    func testColor() {
        XCTAssertEqual(c.classify(text: "#12A877", types: [], source: nil), .color)
        XCTAssertEqual(c.classify(text: "#abc", types: [], source: nil), .color)
        XCTAssertEqual(c.classify(text: "rgb(18, 168, 119)", types: [], source: nil), .color)
    }

    func testLink() {
        XCTAssertEqual(c.classify(text: "https://Latch.app/x", types: [], source: nil), .link)
        XCTAssertEqual(c.classify(text: "mailto:you@Latch.app", types: [], source: nil), .link)
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
