import AppKit

// Entry point. An explicit bootstrap (rather than @main) keeps the AppKit agent-app
// lifecycle clear; all UI work runs on the main thread.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
