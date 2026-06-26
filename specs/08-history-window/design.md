# 08 — History Panel — Design

> Reworked for the Latch two-pane design. Reference:
> `/design/ui_kits/app/LatchPanel.jsx` + `/design/ui_kits/app/index.html` (`.lp*` CSS).

## Files (v0.1 Latch)

```
Sources/PastaApp/HistoryPanelController.swift   # frosted NSPanel host + show/hide/toggle
Sources/PastaApp/HistoryViewModel.swift         # query + filter chip + selection + actions
Sources/PastaApp/HistoryPanel.swift             # SwiftUI: header + FilterBar + list + PreviewPane + footer
Sources/PastaApp/FilterBar.swift                # chip row
Sources/PastaApp/PreviewPane.swift              # right-hand preview + actions
// ClipRow lives in DesignSystem (feature 11)
```

### Layout (from .lp CSS)
- Panel: 720px; `VisualEffectView(.hudWindow)` + paper tint; `Radius.panel`; `Shadow.panel`.
- Header: padding 12/14/10; `PSearchField` (40px tall) + `PBadge(tone:.secure, dot:true)`
  "Local only" + `PIconButton(gear)` → settings.
- `FilterBar`: chips, fully-round; selected = white chip + accent-press text + `Shadow.sm`.
- Body: `HStack`, height ~366; left list pane width 322 (scroll, padding 6, right hairline);
  right `PreviewPane` (flex, padding 18/20).
- Footer: dark glass (`VisualEffectView(.underWindowBackground)` tinted ink), `PKbd(tone:.ink)`
  hints.
- Toast: pill, dark glass, bottom-center, spring-in, auto-dismiss ~1.4s.

## HistoryViewModel

```swift
@MainActor final class HistoryViewModel: ObservableObject {
    @Published var query = "" { didSet { recompute() } }
    @Published var filter: ClipFilter = .all { didSet { recompute() } }
    @Published private(set) var results: [ClipItem] = []
    @Published var selectionIndex = 0
    @Published var toast: String? = nil

    enum ClipFilter { case all, pinned, link, text, code, color }   // chips (08-AC-4)

    init(store: HistoryStore, matcher: FuzzyMatcher, pasteboard: PasteboardWriting)
    func recompute()             // narrow by filter -> fuzzy(query over content+source) -> pinned-first
    func moveSelection(by:Int)   // clamp (08-AC-7)
    func activate(index:Int?)    // copy-back selected/Nth + hide + toast (08-AC-8/10/14)
    func pasteSelected() -> Bool
    func deleteSelected()        // store.remove + reselect neighbor (08-AC-9)
    func togglePinSelected()     // store.togglePin
    func resetForShow()          // query="", filter=.all, selection=0, focus search (08-AC-2)
}
```

## HistoryPanelController

```swift
@MainActor final class HistoryPanelController {
    private let panel: NSPanel              // borderless .nonactivatingPanel, level .floating,
                                            // isFloatingPanel, hidesOnDeactivate, all-spaces
    func show()    // resetForShow; center-top; NSApp.activate; makeKey; focus search (08-AC-1/2/13)
    func hide()    // orderOut (08-AC-11)
    func toggle()  // visible ? hide : show (08-AC-13)
}
```

## Keyboard handling (macOS 13 floor)

A panel-scoped `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` (added on show,
removed on hide): ↑/↓ → moveSelection; Return → activate(nil); ⌘+Delete → deleteSelected;
Esc → hide; digits 1–9 → activate(n-1). Character keys fall through to the search field.

## Copy-back & dedupe (08-AC-8/14)

`pasteSelected` → `pasteboard.write(...)` (text+RTF, or image/file). The write bumps
`changeCount`; the monitor captures it; `HistoryStore.add` dedupes by `contentHash`, moving
it to the top. (While the panel is the foreground action, that's intended.)

## Reference dimensions / styling — original single-pane notes (superseded)

## HistoryViewModel

```swift
@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var query: String = "" { didSet { recompute() } }
    @Published private(set) var results: [ClipItem] = []
    @Published var selectionIndex: Int = 0

    private let store: HistoryStore
    private let matcher: FuzzyMatcher
    private let pasteboard: PasteboardWriting
    // observes store.$items (Combine) -> recompute()

    init(store: HistoryStore, matcher: FuzzyMatcher, pasteboard: PasteboardWriting)

    func recompute()                 // results = matcher.filter(store.items, query); clamp selection -> 0 (08-AC-9)
    func moveSelection(by delta: Int)// clamp within [0, results.count-1] (08-AC-5)
    func copySelected() -> Bool      // write results[selectionIndex] back; true if copied (08-AC-6/11)
    func resetForShow()              // query=""; recompute; selectionIndex=0 (08-AC-2 prep)
}
```

- `copySelected()` calls `pasteboard.write(plainText:rtfData:)`; the store's monitor will
  observe the change and dedupe it to the top (08-AC-11). No direct store mutation needed.
- Subscribes to `store.$items` so live captures update the list while open.

## HistoryWindowController

```swift
@MainActor
final class HistoryWindowController {
    private let panel: NSPanel
    private let viewModel: HistoryViewModel

    init(store: HistoryStore, pasteboard: PasteboardWriting, matcher: FuzzyMatcher)

    func show()      // resetForShow(); center; orderFrontRegardless; makeKey; focus search
    func hide()      // orderOut(nil)
    func toggle()    // panel.isVisible ? hide() : show()   (08-AC-10)
}
```

- `panel`: `NSPanel` with style `[.titled?, .nonactivatingPanel]` — use a borderless,
  floating, non-activating panel: `level = .floating`, `isFloatingPanel = true`,
  `hidesOnDeactivate = true`, `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]`.
  Content is the SwiftUI `HistoryListView` via `NSHostingView`.
- `hidesOnDeactivate = true` (or observing `didResignKeyNotification`) implements 08-AC-8.
- `show()` calls `NSApp.activate(ignoringOtherApps: true)` then makes the panel key so the
  search field can receive input even though the app is an agent (08-AC-2).

## HistoryListView (SwiftUI)

```swift
struct HistoryListView: View {
    @ObservedObject var vm: HistoryViewModel
    var onCommit: () -> Void     // copy + hide (Enter / double-click)
    var onCancel: () -> Void     // hide (Esc)
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search…", text: $vm.query)
                .focused($searchFocused)
                .textFieldStyle(.plain)
            Divider()
            List(selection: …) {
                ForEach(Array(vm.results.enumerated()), id: \.element.id) { idx, item in
                    HistoryRow(item: item, selected: idx == vm.selectionIndex)
                        .onTapGesture(count: 2) { vm.selectionIndex = idx; onCommit() }
                }
            }
        }
        .onAppear { searchFocused = true }            // 08-AC-2
    }
}
```

### Keyboard handling (macOS 13 floor)

`.onKeyPress` is macOS 14+. To support the 13.0 floor, intercept keys with a small
`NSViewRepresentable` "key catcher" or override in the hosting panel's responder chain:

- ↑ / ↓ → `vm.moveSelection(by: -1 / +1)` (08-AC-5)
- Return → `onCommit()` (08-AC-6)
- Esc → `onCancel()` (08-AC-7)

Implementation option: a custom `NSHostingView` subclass (or an injected key-monitor via
`NSEvent.addLocalMonitorForEvents(matching: .keyDown)`) that maps these keys and consumes
them before the text field, while letting character keys flow to the search field. The
local monitor is scoped to the panel's lifetime (added on show, removed on hide).

## Copy-back flow (08-AC-6 / 08-AC-11)

```
onCommit: { if vm.copySelected() { controller.hide() } }
vm.copySelected: pasteboard.write(plainText: item.plainText, rtfData: item.rtfData)
```

The write bumps `changeCount`; `ClipboardMonitor` captures it; `HistoryStore.add` dedupes
by `contentHash`, moving the item to the top instead of duplicating (08-AC-11).

## Edge cases

- Empty results (query matches nothing): selection clamps to a valid range; Enter is a
  no-op (`copySelected` returns false → window stays open).
- New capture arrives while open: list updates; current selection index clamps if it now
  exceeds bounds.
- Window re-shown: query reset to empty, selection at top (resetForShow).
- Agent app focus: must `NSApp.activate` so the panel can become key and accept typing.
