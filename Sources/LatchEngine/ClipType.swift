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
