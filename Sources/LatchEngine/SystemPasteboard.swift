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
