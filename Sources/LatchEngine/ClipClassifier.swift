import Foundation

/// Classifies a clip into a `ClipType`. Pure logic, unit-testable without a pasteboard.
/// Precedence: file → image → color → link → code → text. See specs/12-type-detection.
public struct ClipClassifier {
    public static let devApps: Set<String> = [
        "Terminal", "iTerm2", "iTerm", "Xcode", "Visual Studio Code", "Code",
        "Ghostty", "Warp", "Sublime Text", "Nova", "Zed", "Hyper",
    ]

    public init() {}

    public func classify(text: String?, types: [String], source: String?) -> ClipType {
        let typeSet = Set(types)
        let trimmed = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmed.isEmpty

        let hasFile = typeSet.contains(PasteboardType.fileURL)
        let hasImage = typeSet.contains(PasteboardType.tiff)
            || typeSet.contains(PasteboardType.png)
            || types.contains { $0.hasPrefix("public.image") }

        if hasFile, !hasText { return .file }
        if hasImage, !hasText { return .image }
        if hasText {
            if ClipClassifier.isColor(trimmed) { return .color }
            if ClipClassifier.isSingleURL(trimmed) { return .link }
            if looksLikeCode(trimmed, source: source) { return .code }
        }
        if hasFile { return .file }
        if hasImage { return .image }
        return .text
    }

    // MARK: - Heuristics

    static func isColor(_ s: String) -> Bool {
        matchesWhole(s, "^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")
            || matchesWhole(s, "^rgba?\\([0-9.,%\\s]+\\)$")
    }

    static func isSingleURL(_ s: String) -> Bool {
        // No internal whitespace, single token.
        guard !s.contains(where: { $0 == " " || $0 == "\n" || $0 == "\t" }) else { return false }
        if s.lowercased().hasPrefix("mailto:") { return true }
        if let url = URL(string: s), let scheme = url.scheme, scheme == "http" || scheme == "https", url.host != nil {
            return true
        }
        // Bare domain like example.com/path
        return matchesWhole(s, "^[a-z0-9.-]+\\.[a-z]{2,}(/\\S*)?$")
    }

    /// Whole-string, case-insensitive regex match.
    private static func matchesWhole(_ s: String, _ pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return false }
        return regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
    }

    func looksLikeCode(_ s: String, source: String?) -> Bool {
        if let src = source, ClipClassifier.devApps.contains(src) { return true }

        let commandPrefixes = ["git ", "npm ", "yarn ", "pnpm ", "cd ", "sudo ", "brew ",
                               "docker ", "kubectl ", "$ ", "make ", "python ", "pip ", "swift "]
        let lower = s.lowercased()
        if commandPrefixes.contains(where: { lower.hasPrefix($0) }) { return true }

        // Multi-line with code-punctuation density.
        if s.contains("\n") {
            let codeChars = Set("{}();=<>/|$[]")
            let count = s.reduce(0) { $0 + (codeChars.contains($1) ? 1 : 0) }
            let density = Double(count) / Double(max(s.count, 1))
            if density > 0.03 { return true }
        }
        return false
    }
}
