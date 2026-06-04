import AppKit
import SwiftUI

/// Hosts `SettingsView` in a plain AppKit window. Opening the SwiftUI `Settings`
/// scene programmatically is disallowed on macOS 14+ ("use SettingsLink"), so we
/// drive our own window from the status menu instead. Reuses a single window.
@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private let env: AppEnvironment

    init(env: AppEnvironment) {
        self.env = env
    }

    func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: SettingsView(env: env))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 460, height: 430),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            window.title = "Waggle Settings"
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
