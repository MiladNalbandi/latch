# 12 — Type Detection — Design

## Files

```
Sources/PastaEngine/ClipType.swift        # enum + SF Symbol + tile styling key
Sources/PastaEngine/ClipClassifier.swift  # pure classification
```

## ClipType

```swift
public enum ClipType: String, Codable, CaseIterable {
    case text, link, code, color, image, file
    public var symbolName: String {   // SF Symbols (Lucide substitutes)
        switch self {
        case .text:  return "textformat"
        case .link:  return "link"
        case .code:  return "chevron.left.forwardslash.chevron.right"
        case .color: return "paintpalette"
        case .image: return "photo"
        case .file:  return "doc"
        }
    }
}
```

## ClipClassifier

```swift
public struct ClipClassifier {
    public static let devApps: Set<String> = ["Terminal","iTerm2","Xcode","Visual Studio Code","Code","Ghostty","Warp"]
    public init()
    public func classify(text: String?, types: [String], source: String?) -> ClipType
}
```

### Algorithm (precedence file → image → color → link → code → text; 12-AC-9)

```
let hasFileURL = types.contains("public.file-url")
let hasImage   = types.contains { $0 == "public.tiff" || $0 == "public.png" || $0.hasPrefix("public.image") }
let t = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

if hasFileURL && t.isEmpty?(or no meaningful text) { return .file }     // 12-AC-2
if hasImage   && t.isEmpty                          { return .image }    // 12-AC-3
if isHexColor(t) || isRGBColor(t)                   { return .color }    // 12-AC-4
if isSingleURL(t)                                   { return .link }     // 12-AC-5
if looksLikeCode(t, source)                         { return .code }     // 12-AC-6
return .text                                                             // 12-AC-7
```

Helpers:
- `isHexColor`: regex `^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$`.
- `isRGBColor`: `^rgba?\([0-9.,%\s]+\)$` (case-insensitive).
- `isSingleURL`: no internal whitespace AND (`http(s)://…` via `URL`/`NSDataDetector`
  spanning the whole string, OR `mailto:`, OR a bare `host.tld[/path]`).
- `looksLikeCode`: `devApps.contains(source ?? "")` OR (contains newline AND code-punctuation
  density over a threshold, e.g. ratio of `{}();=<>/|$` and indentation) OR matches common
  command prefixes (`git `, `npm `, `cd `, `sudo `, `brew `, `$ `).

## Integration

`ClipboardMonitor` (feature 01) calls `classifier.classify(...)` after reading content and
sets `ClipItem.type`. `source` comes from `SourceProvider` (feature 01).

## Edge cases

- File + caption text present: if the text is just the filename/path, still `file`;
  if substantive text accompanies, prefer the text classification (config: treat as file
  only when text is empty or equals the path).
- Very long text that happens to start with `git`: code heuristic is best-effort; false
  positives degrade gracefully (just a different icon).
- 3-digit hex (`#abc`) supported; 8-digit (`#rrggbbaa`) optional.
