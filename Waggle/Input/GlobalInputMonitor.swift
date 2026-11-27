import AppKit
import Combine

/// Owns the input trackers and translates raw input into dog-relative signals
/// on the `DogViewModel`: cursor proximity/direction and generic typing
/// activity. Trackers exist only while their reactions are enabled.
@MainActor
final class GlobalInputMonitor {
    private let cursorTracker = CursorTracker()
    private let typingTracker = TypingTracker()
    private let dogViewModel: DogViewModel
    private let permission: AccessibilityPermissionManager
    /// Current dog center in screen coordinates, or `nil` if the overlay is gone.
    private let dogCenter: () -> CGPoint?

    private var permissionCancellable: AnyCancellable?
    private var leftClickMonitor: Any?
    private var rightClickMonitor: Any?
    private var isRunning = false

    // Cursor movement tracking for idle reset.
    private var lastCursorPos: CGPoint = .zero

    /// Reaction toggles (set from settings / pause).
    private var cursorEnabled = true
    private var typingEnabled = true
    private var reactionsPaused = false

    /// Within this distance the dog watches the cursor.
    private let nearRadius: CGFloat = 240
    /// Within this (smaller) distance the dog gets excited.
    private let excitedRadius: CGFloat = 90

    init(
        dogViewModel: DogViewModel,
        permission: AccessibilityPermissionManager,
        dogCenter: @escaping () -> CGPoint?
    ) {
        self.dogViewModel = dogViewModel
        self.permission = permission
        self.dogCenter = dogCenter
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        dogViewModel.startIdleTracking()

        cursorTracker.onMove = { [weak self] location in
            self?.handleCursor(at: location)
        }

        typingTracker.onTypingChanged = { [weak self] typing in
            guard let self, self.typingEnabled, !self.reactionsPaused else { return }
            self.dogViewModel.setTyping(typing)
        }
        typingTracker.onKeyDown = { [weak self] in
            guard let self, self.typingEnabled, !self.reactionsPaused else { return }
            self.dogViewModel.registerKeystroke()
        }

        updateCursorMonitor()
        updateClickMonitors()

        // Start/stop keyboard monitoring as Accessibility permission changes.
        // Sinking on @Published delivers the current value immediately, so this
        // also handles the already-trusted case.
        permissionCancellable = permission.$isTrusted
            .removeDuplicates()
            .sink { [weak self] trusted in
                self?.updateTypingMonitor(trusted: trusted)
            }
    }

    func stop() {
        isRunning = false
        cursorTracker.stop()
        typingTracker.stop()
        permissionCancellable = nil
        removeClickMonitors()
    }

    /// Enable/disable each reaction; clears any lingering state when turned off.
    func setReactions(cursor: Bool, typing: Bool, paused: Bool) {
        cursorEnabled = cursor
        typingEnabled = typing
        reactionsPaused = paused
        if !cursor || paused { dogViewModel.updateCursor(direction: nil, excited: false, angle: nil) }
        if !typing || paused { dogViewModel.setTyping(false) }
        updateCursorMonitor()
        updateTypingMonitor(trusted: permission.isTrusted)
        updateClickMonitors()
    }

    private func updateCursorMonitor() {
        if isRunning && cursorEnabled && !reactionsPaused {
            cursorTracker.start()
        } else {
            cursorTracker.stop()
        }
    }

    /// Keep the global keyboard monitor alive only while the user has both
    /// granted Accessibility access and enabled typing reactions.
    private func updateTypingMonitor(trusted: Bool) {
        if isRunning && trusted && typingEnabled && !reactionsPaused {
            typingTracker.start()
        } else {
            typingTracker.stop()
        }
    }

    /// Click reactions have no individual toggle, but Pause All Reactions must
    /// remove their global monitors as well.
    private func updateClickMonitors() {
        guard isRunning && !reactionsPaused else {
            removeClickMonitors()
            return
        }
        if leftClickMonitor == nil {
            leftClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] _ in
                Task { @MainActor in
                    guard let self, !self.reactionsPaused else { return }
                    self.dogViewModel.flapLeftEar()
                }
            }
        }
        if rightClickMonitor == nil {
            rightClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown) { [weak self] _ in
                Task { @MainActor in
                    guard let self, !self.reactionsPaused else { return }
                    self.dogViewModel.flapRightEar()
                }
            }
        }
    }

    private func removeClickMonitors() {
        if let monitor = leftClickMonitor { NSEvent.removeMonitor(monitor) }
        if let monitor = rightClickMonitor { NSEvent.removeMonitor(monitor) }
        leftClickMonitor = nil
        rightClickMonitor = nil
    }

    private func handleCursor(at location: CGPoint) {
        // Track movement for idle reset.
        let moveDist = (pow(location.x - lastCursorPos.x, 2) + pow(location.y - lastCursorPos.y, 2)).squareRoot()
        lastCursorPos = location
        if moveDist > 1 { dogViewModel.resetIdleTimer() }

        guard cursorEnabled, !reactionsPaused, let center = dogCenter() else {
            dogViewModel.updateCursor(direction: nil, excited: false, angle: nil)
            return
        }

        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = (dx * dx + dy * dy).squareRoot()

        guard distance <= nearRadius else {
            dogViewModel.updateCursor(direction: nil, excited: false, angle: nil)
            return
        }

        dogViewModel.updateCursor(
            direction: DogDirection.from(dx: dx, dy: dy),
            excited: distance <= excitedRadius,
            angle: atan2(dy, dx) * 180 / .pi
        )
    }
}
