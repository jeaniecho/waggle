import AppKit
import Combine

/// Owns the input trackers and translates raw input into dog-relative signals
/// on the `DogViewModel`: cursor proximity/direction (always) and generic
/// typing activity (only while Accessibility permission is granted).
@MainActor
final class GlobalInputMonitor {
    private let cursorTracker = CursorTracker()
    private let typingTracker = TypingTracker()
    private let dogViewModel: DogViewModel
    private let permission: AccessibilityPermissionManager
    /// Current dog center in screen coordinates, or `nil` if the overlay is gone.
    private let dogCenter: () -> CGPoint?

    private var permissionCancellable: AnyCancellable?

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
        cursorTracker.onMove = { [weak self] location in
            self?.handleCursor(at: location)
        }
        cursorTracker.start()

        typingTracker.onTypingChanged = { [weak self] typing in
            self?.dogViewModel.setTyping(typing)
        }
        typingTracker.onKeyDown = { [weak self] in
            self?.dogViewModel.registerKeystroke()
        }
        // Start/stop keyboard monitoring as Accessibility permission changes.
        // Sinking on @Published delivers the current value immediately, so this
        // also handles the already-trusted case.
        permissionCancellable = permission.$isTrusted
            .removeDuplicates()
            .sink { [weak self] trusted in
                if trusted {
                    self?.typingTracker.start()
                } else {
                    self?.typingTracker.stop()
                }
            }
    }

    func stop() {
        cursorTracker.stop()
        typingTracker.stop()
        permissionCancellable = nil
    }

    private func handleCursor(at location: CGPoint) {
        guard let center = dogCenter() else {
            dogViewModel.updateCursor(direction: nil, excited: false)
            return
        }

        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = (dx * dx + dy * dy).squareRoot()

        guard distance <= nearRadius else {
            dogViewModel.updateCursor(direction: nil, excited: false)
            return
        }

        dogViewModel.updateCursor(
            direction: DogDirection.from(dx: dx, dy: dy),
            excited: distance <= excitedRadius
        )
    }
}
