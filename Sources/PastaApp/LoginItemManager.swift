import Foundation
import ServiceManagement

/// Wraps `SMAppService.mainApp` for launch-at-login. See specs/10-launch-at-login.
final class LoginItemManager {
    var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    @discardableResult
    func setEnabled(_ enabled: Bool) -> Result<Void, Error> {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
