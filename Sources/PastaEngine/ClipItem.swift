import Foundation
import CryptoKit
#if canImport(AppKit)
import AppKit
#endif

/// A single captured clipboard entry. Carries plain text and/or RTF, plus optional
/// image/file payloads, a derived single-line `preview`, a `contentHash` for dedupe,
/// the detected `type`, the originating app `source`, and `pinned` state.
///
/// See specs/01-pasteboard-monitor, /03-history-store, /12-type-detection.
public struct ClipItem: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    /// Mutable so dedupe can bump recency when the same content is re-copied.
    public var createdAt: Date
    public var plainText: String?
    public var rtfData: Data?
    /// PNG data for `image` clips (downscaled thumbnail acceptable for preview).
    public var imageData: Data?
    /// Absolute file path for `file` clips.
    public var fileURLPath: String?

    public var type: ClipType
    public var source: String?
    public var pinned: Bool

    public let preview: String
    public let contentHash: String

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        plainText: String? = nil,
        rtfData: Data? = nil,
        imageData: Data? = nil,
        fileURLPath: String? = nil,
        type: ClipType = .text,
        source: String? = nil,
        pinned: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.plainText = plainText
        self.rtfData = rtfData
        self.imageData = imageData
        self.fileURLPath = fileURLPath
        self.type = type
        self.source = source
        self.pinned = pinned
        self.preview = ClipItem.makePreview(
            plainText: plainText, rtfData: rtfData,
            fileURLPath: fileURLPath, type: type
        )
        self.contentHash = ClipItem.makeHash(
            plainText: plainText, rtfData: rtfData,
            imageData: imageData, fileURLPath: fileURLPath
        )
    }

    /// Character count of the textual content (for the preview meta line).
    public var characterCount: Int { (plainText ?? preview).count }

    // MARK: - Derivation

    /// A trimmed, single-line, truncated display string.
    static func makePreview(plainText: String?, rtfData: Data?, fileURLPath: String?, type: ClipType) -> String {
        let raw: String
        if let t = plainText, !t.isEmpty {
            raw = t
        } else if let path = fileURLPath {
            raw = (path as NSString).lastPathComponent
        } else if rtfData != nil {
            raw = ClipItem.plainText(fromRTF: rtfData) ?? "Rich text"
        } else if type == .image {
            raw = "Image"
        } else {
            raw = ""
        }
        let collapsed = raw
            .replacingOccurrences(of: "\r\n", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let squeezed = collapsed.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if squeezed.count <= 200 { return squeezed }
        return String(squeezed.prefix(200)) + "…"
    }

    /// Stable dedupe key over the normalized content.
    static func makeHash(plainText: String?, rtfData: Data?, imageData: Data?, fileURLPath: String?) -> String {
        var hasher = SHA256()
        if let t = plainText { hasher.update(data: Data(("t:" + t).utf8)) }
        if let r = rtfData { hasher.update(data: Data("r:".utf8)); hasher.update(data: r) }
        if let i = imageData { hasher.update(data: Data("i:".utf8)); hasher.update(data: i) }
        if let f = fileURLPath { hasher.update(data: Data(("f:" + f).utf8)) }
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Best-effort plain-text rendering of RTF data (no AppKit dependency here).
    static func plainText(fromRTF data: Data?) -> String? {
        guard let data = data,
              let s = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
              ) else { return nil }
        return s.string
    }
}
