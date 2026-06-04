import Foundation
import ServiceManagement

/// Wraps "launch at login" via `SMAppService` (macOS 13+). On macOS 12 the
/// option is unavailable and reports as off.
@MainActor
final class LoginItemManager {
    /// Whether the OS supports the modern login-item API.
    var isAvailable: Bool {
        if #available(macOS 13.0, *) { return true }
        return false
    }

    var isEnabled: Bool {
        guard #available(macOS 13.0, *) else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else { return }
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            Log.lifecycle.error("Login item toggle failed: \(error.localizedDescription)")
        }
    }
}
