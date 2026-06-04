import AppKit
import ApplicationServices

/// Checks and publishes whether Waggle is trusted for Accessibility, and offers
/// ways to request it / open the relevant System Settings pane.
///
/// Accessibility permission is only needed for global keyboard monitoring
/// (Task 005); the app stays fully usable without it (dragging and cursor
/// reactions work regardless). macOS does not notify us when the grant changes,
/// so we poll while untrusted and stop once granted.
@MainActor
final class AccessibilityPermissionManager: ObservableObject {
    @Published private(set) var isTrusted: Bool

    private var pollTimer: Timer?
    private let pollInterval: TimeInterval = 2.0

    init() {
        isTrusted = AXIsProcessTrusted()
    }

    /// Re-read the current trust state. Stops polling once trusted.
    func refresh() {
        let trusted = AXIsProcessTrusted()
        if trusted != isTrusted {
            isTrusted = trusted
        }
        if trusted {
            stopPolling()
        } else {
            startPolling()
        }
    }

    /// Show the system Accessibility prompt (only appears the first time per
    /// app) and begin polling for the result.
    func requestPermission() {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
        startPolling()
    }

    /// Guide the user to grant Accessibility: registers the app (so it appears
    /// in the list with a toggle), shows the system prompt, and opens the pane.
    func promptForAccessibility() {
        requestPermission()
        openSystemSettings()
    }

    /// Open System Settings directly at Privacy & Security → Accessibility.
    func openSystemSettings() {
        guard let url = URL(string:
            "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        else { return }
        NSWorkspace.shared.open(url)
        startPolling()
    }

    // MARK: - Polling

    private func startPolling() {
        guard pollTimer == nil, !isTrusted else { return }
        pollTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    private func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    deinit {
        pollTimer?.invalidate()
    }
}
