import Foundation
#if canImport(AppKit)
import AppKit

/// The single place that touches `NSPasteboard.general`. Implements both read and write
/// sides plus the frontmost-app source provider.
public final class SystemPasteboard: PasteboardReading, PasteboardWriting, SourceProviding {
    private let pasteboard: NSPasteboard

    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }

    // MARK: PasteboardReading

    public var changeCount: Int { pasteboard.changeCount }

    public func availableTypes() -> [String] {
        (pasteboard.types ?? []).map(\.rawValue)
    }

    public func string(forType type: String) -> String? {
        pasteboard.string(forType: NSPasteboard.PasteboardType(type))
    }

    public func data(forType type: String) -> Data? {
        pasteboard.data(forType: NSPasteboard.PasteboardType(type))
    }

    // MARK: PasteboardWriting (copy-back)

    public func write(_ item: ClipItem) {
        pasteboard.clearContents()
        if let rtf = item.rtfData {
            pasteboard.setData(rtf, forType: NSPasteboard.PasteboardType(PasteboardType.rtf))
        }
        if let text = item.plainText {
            pasteboard.setString(text, forType: NSPasteboard.PasteboardType(PasteboardType.plainText))
        }
        if let png = item.imageData {
            pasteboard.setData(png, forType: NSPasteboard.PasteboardType(PasteboardType.png))
        }
        if let path = item.fileURLPath {
            let url = URL(fileURLWithPath: path)
            pasteboard.setString(url.absoluteString, forType: NSPasteboard.PasteboardType(PasteboardType.fileURL))
        }
    }

    // MARK: SourceProviding

    public func currentSourceName() -> String? {
        NSWorkspace.shared.frontmostApplication?.localizedName
    }
}
#endif
