import AppKit

/// Owns app lifecycle and creates the shared environment + overlay window.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var environment: AppEnvironment?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let environment = AppEnvironment()
        self.environment = environment
        environment.showOverlay()
    }

    /// Waggle is a menu-bar / overlay app: it has no ordinary windows, and the
    /// transparent dog overlay is a borderless `NSPanel` that AppKit does not
    /// count as a window. Returning `true` here made the app quit itself the
    /// moment a status-bar menu opened and closed (the menu's transient window
    /// being treated as the "last" window). Quitting is done explicitly from the
    /// menu bar, so never auto-terminate.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
