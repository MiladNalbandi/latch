# 10 — Launch at Login — Design

## Files

```
Sources/LatchApp/LoginItemManager.swift
```

Uses `ServiceManagement` (`SMAppService`), available on macOS 13+ (matches our floor).

## LoginItemManager

```swift
import ServiceManagement

final class LoginItemManager {
    var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled          // 10-AC-3
    }

    @discardableResult
    func setEnabled(_ enabled: Bool) -> Result<Void, Error> {
        do {
            if enabled {
                try SMAppService.mainApp.register()      // 10-AC-1
            } else {
                try SMAppService.mainApp.unregister()    // 10-AC-2
            }
            return .success(())
        } catch {
            return .failure(error)                       // 10-AC-4 (caller surfaces)
        }
    }
}
```

## Integration with Preferences (feature 09)

The toggle binding:

```swift
var loginItemBinding: Binding<Bool> {
    Binding(
        get: { loginItem.isEnabled },                    // 10-AC-3 / 10-AC-5
        set: { newValue in
            if case .failure(let err) = loginItem.setEnabled(newValue) {
                // present a non-fatal alert; toggle re-reads isEnabled (10-AC-4)
            }
        }
    )
}
```

After a failed set, the binding's `get` re-reads `SMAppService.mainApp.status`, so the UI
snaps back to the true state (10-AC-4).

## Notes / edge cases

- `SMAppService.mainApp.register()` may surface a system prompt or require the app to be in
  `/Applications` and properly signed for the login item to persist reliably. For unsigned
  dev builds, the toggle may show a "needs approval" state in System Settings → Login
  Items; document this in the README QA notes.
- `.status` can be `.requiresApproval`; treat anything other than `.enabled` as "off" for
  the toggle's `get`, optionally surfacing a hint to approve in System Settings.
- No persistence of our own is needed — `SMAppService` is the source of truth.

## Testing

System-integration; not unit-tested in `LatchEngineTests`. Verified manually (toggle on →
appears in Login Items; relaunch at next login). The `LoginItemManager` lives in the app
target (not the engine) since it's pure system glue.
