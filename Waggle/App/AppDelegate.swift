import AppKit

/// Owns app lifecycle and creates the shared environment + overlay window.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var environment: AppEnvironment?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let environment = AppEnvironment()
        self.environment = environment
        environment.showOverlay()
    }

    /// The overlay is the whole point of the app; quit when it would otherwise
    /// be left running with no windows.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}
