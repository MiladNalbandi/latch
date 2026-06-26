import Foundation

/// Observes screen-lock to support "clear history when Mac locks". See specs/13.
final class LockMonitor {
    private let onLock: () -> Void

    init(onLock: @escaping () -> Void) {
        self.onLock = onLock
        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screenIsLocked"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onLock()
        }
    }
}
