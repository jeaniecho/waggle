import AppKit

/// Detects *generic* typing activity via a global key-down monitor and reports
/// a debounced typing on/off signal.
///
/// Privacy (PRIVACY.md): the key-down handler ignores the event entirely — no
/// key code, character, modifier, or text is read or stored. We only learn that
/// *some* key was pressed.
///
/// Global key-down monitoring requires Accessibility permission, so the owner
/// only starts this tracker once trusted (see GlobalInputMonitor).
@MainActor
final class TypingTracker {
    /// Called with `true` when typing starts and `false` after a quiet period.
    var onTypingChanged: ((Bool) -> Void)?
    /// Called once per keystroke (no key content) to drive per-key reactions.
    var onKeyDown: (() -> Void)?

    private var monitor: Any?
    private var isTyping = false

    /// Spec suggests 600–1000ms of inactivity to end the typing state.
    private let debouncer = Debouncer(interval: 0.8)

    func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] _ in
            self?.handleKeyDown()
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        debouncer.cancel()
        setTyping(false)
    }

    private func handleKeyDown() {
        onKeyDown?()
        setTyping(true)
        // Each keystroke pushes the "stopped typing" moment further out, so
        // continuous typing keeps the state active.
        debouncer.call { [weak self] in
            self?.setTyping(false)
        }
    }

    private func setTyping(_ typing: Bool) {
        guard isTyping != typing else { return }
        isTyping = typing
        onTypingChanged?(typing)
    }

    deinit {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
