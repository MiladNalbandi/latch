import Foundation

/// Polls the pasteboard `changeCount` and, on change, captures a new `ClipItem` (text,
/// RTF, image, or file) — applying the privacy filter and incognito pause first, then
/// recording the source app and classifying the type. See specs/01-pasteboard-monitor.
public final class ClipboardMonitor {
    public var onCapture: ((ClipItem) -> Void)?

    /// While paused (incognito), nothing is captured but `lastChangeCount` keeps tracking
    /// so resuming doesn't back-fill. See specs/13-pinning-lifecycle.
    public var isPaused: Bool = false

    public var filter: PrivacyFilter

    private let pasteboard: PasteboardReading
    private let classifier: ClipClassifier
    private let source: SourceProviding?
    private let queue: DispatchQueue

    private var interval: TimeInterval
    private var timer: DispatchSourceTimer?
    private var lastChangeCount: Int = -1
    /// Cap for captured image payloads; larger images are downscaled by the app layer.
    private let maxImageBytes: Int

    public init(
        pasteboard: PasteboardReading,
        classifier: ClipClassifier = ClipClassifier(),
        filter: PrivacyFilter = PrivacyFilter(),
        source: SourceProviding? = nil,
        interval: TimeInterval = 0.5,
        queue: DispatchQueue = .main,
        maxImageBytes: Int = 8 * 1024 * 1024
    ) {
        self.pasteboard = pasteboard
        self.classifier = classifier
        self.filter = filter
        self.source = source
        self.interval = interval
        self.queue = queue
        self.maxImageBytes = maxImageBytes
    }

    deinit { stop() }

    // MARK: - Lifecycle

    public func start() {
        // Seed lastChangeCount so existing clipboard content isn't captured at launch.
        lastChangeCount = pasteboard.changeCount
        scheduleTimer()
    }

    public func stop() {
        timer?.cancel()
        timer = nil
    }

    /// Apply a new poll interval without dropping `lastChangeCount` (no spurious recapture).
    public func setInterval(_ newInterval: TimeInterval) {
        interval = newInterval
        if timer != nil { scheduleTimer() }
    }

    private func scheduleTimer() {
        timer?.cancel()
        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + interval, repeating: interval)
        t.setEventHandler { [weak self] in self?.poll() }
        timer = t
        t.resume()
    }

    // MARK: - Polling

    /// Exposed for tests (manual tick).
    public func poll() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current

        // Incognito: swallow the change so resume doesn't back-fill.
        if isPaused { return }

        let types = pasteboard.availableTypes()
        if filter.shouldSkip(types: types) { return }

        let plain = nonEmpty(pasteboard.string(forType: PasteboardType.plainText))
        let rtf = pasteboard.data(forType: PasteboardType.rtf)

        var imageData: Data?
        var filePath: String?
        let typeSet = Set(types)
        if plain == nil && rtf == nil {
            if typeSet.contains(PasteboardType.png) {
                imageData = capped(pasteboard.data(forType: PasteboardType.png))
            } else if typeSet.contains(PasteboardType.tiff) {
                imageData = capped(pasteboard.data(forType: PasteboardType.tiff))
            }
            if let urlString = pasteboard.string(forType: PasteboardType.fileURL),
               let url = URL(string: urlString), url.isFileURL {
                filePath = url.path
            }
        }

        guard plain != nil || rtf != nil || imageData != nil || filePath != nil else { return }

        let sourceName = source?.currentSourceName()
        let type = classifier.classify(text: plain, types: types, source: sourceName)

        let item = ClipItem(
            plainText: plain,
            rtfData: rtf,
            imageData: imageData,
            fileURLPath: filePath,
            type: type,
            source: sourceName
        )
        onCapture?(item)
    }

    private func nonEmpty(_ s: String?) -> String? {
        guard let s = s, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return s
    }

    private func capped(_ data: Data?) -> Data? {
        guard let data = data else { return nil }
        return data.count <= maxImageBytes ? data : nil
    }
}
