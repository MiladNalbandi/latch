import AppKit

// Entry point. Using an explicit bootstrap (rather than @main) keeps the AppKit
// agent-app lifecycle clear and lets AppDelegate be @MainActor.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
