import XCTest
@testable import PastaEngine

final class ClipboardMonitorTests: XCTestCase {
    private func makeMonitor(_ pb: FakePasteboard, source: String? = nil, filter: PrivacyFilter = PrivacyFilter())
        -> (ClipboardMonitor, Box) {
        let box = Box()
        let m = ClipboardMonitor(
            pasteboard: pb,
            classifier: ClipClassifier(),
            filter: filter,
            source: FakeSource(source),
            interval: 0.5
        )
        m.onCapture = { box.captured.append($0) }
        return (m, box)
    }

    final class Box { var captured: [ClipItem] = [] }

    func testCapturesPlainTextOnce() {
        let pb = FakePasteboard()
        let (m, box) = makeMonitor(pb, source: "Mail")
        pb.put(types: [PasteboardType.plainText], strings: [PasteboardType.plainText: "hello"])
        m.poll()
        XCTAssertEqual(box.captured.count, 1)
        XCTAssertEqual(box.captured.first?.plainText, "hello")
        XCTAssertEqual(box.captured.first?.source, "Mail")
    }

    func testNoChangeNoCapture() {
        let pb = FakePasteboard()
        let (m, box) = makeMonitor(pb)
        pb.put(types: [PasteboardType.plainText], strings: [PasteboardType.plainText: "x"])
        m.poll()
        m.poll()   // changeCount unchanged
        XCTAssertEqual(box.captured.count, 1)
    }

    func testEmptyContentIgnored() {
        let pb = FakePasteboard()
        let (m, box) = makeMonitor(pb)
        pb.put(types: ["public.color"])   // no text/rtf/image/file
        m.poll()
        XCTAssertTrue(box.captured.isEmpty)
    }

    func testConcealedNeverReadOrCaptured() {
        let pb = FakePasteboard()
        let (m, box) = makeMonitor(pb)
        pb.put(types: [PasteboardType.concealed, PasteboardType.plainText],
               strings: [PasteboardType.plainText: "s3cret"])
        m.poll()
        XCTAssertTrue(box.captured.isEmpty)
        XCTAssertFalse(pb.stringReads.contains(PasteboardType.plainText))  // never read
    }

    func testIncognitoPausesWithoutBackfill() {
        let pb = FakePasteboard()
        let (m, box) = makeMonitor(pb)
        m.isPaused = true
        pb.put(types: [PasteboardType.plainText], strings: [PasteboardType.plainText: "while paused"])
        m.poll()
        XCTAssertTrue(box.captured.isEmpty)

        // Resume; no new copy. The paused copy must not be back-filled.
        m.isPaused = false
        m.poll()
        XCTAssertTrue(box.captured.isEmpty)

        // A fresh copy after resume is captured.
        pb.put(types: [PasteboardType.plainText], strings: [PasteboardType.plainText: "after"])
        m.poll()
        XCTAssertEqual(box.captured.map(\.plainText), ["after"])
    }

    func testIdenticalTextSameHash() {
        let a = ClipItem(plainText: "same", type: .text)
        let b = ClipItem(plainText: "same", type: .text)
        XCTAssertEqual(a.contentHash, b.contentHash)
    }
}
