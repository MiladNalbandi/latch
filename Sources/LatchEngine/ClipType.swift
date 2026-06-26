import Foundation

/// The kind of content a clip holds. Drives the panel's icon tile, preview, and
/// filter chips. See specs/12-type-detection.
public enum ClipType: String, Codable, CaseIterable, Sendable {
    case text
    case link
    case code
    case color
    case image
    case file

    /// SF Symbol used for the type tile (Lucide substitutes).
    public var symbolName: String {
        switch self {
        case .text:  return "textformat"
        case .link:  return "link"
        case .code:  return "chevron.left.forwardslash.chevron.right"
        case .color: return "paintpalette"
        case .image: return "photo"
        case .file:  return "doc"
        }
    }

    /// Human label used in badges and filter chips.
    public var label: String {
        switch self {
        case .text:  return "Text"
        case .link:  return "Link"
        case .code:  return "Code"
        case .color: return "Color"
        case .image: return "Image"
        case .file:  return "File"
        }
    }
}
