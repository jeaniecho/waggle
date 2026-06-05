import AppKit

/// Observes global cursor movement and reports the current cursor location in
/// screen coordinates (bottom-left origin).
///
/// Mouse-move monitoring does not require Accessibility permission (only
/// keyboard monitoring does — see Task 004). Per PRIVACY.md no cursor history
/// is stored; each move is reported and discarded.
final class CursorTracker {
    /// Called on the main thread with the cursor's current screen location.
    var onMove: ((CGPoint) -> Void)?

    private var globalMonitor: Any?
    private var localMonitor: Any?

    private let matching: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDragged]

    /// Throttle: only forward cursor events at most 30× per second.
    private let reportInterval: TimeInterval = 1.0 / 30.0
    private var lastReportTime: TimeInterval = 0

    func start() {
        guard globalMonitor == nil, localMonitor == nil else { return }

        // Movement over other apps / the desktop.
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: matching) { [weak self] _ in
            self?.report()
        }
        // Movement over our own overlay window (local events must be returned).
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: matching) { [weak self] event in
            self?.report()
            return event
        }
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    private func report() {
        let now = Date().timeIntervalSinceReferenceDate
        guard now - lastReportTime >= reportInterval else { return }
        lastReportTime = now
        onMove?(NSEvent.mouseLocation)
    }

    deinit {
        stop()
    }
}
