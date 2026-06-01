import AppKit

/// Owns the input trackers and translates raw input into dog-relative signals
/// on the `DogViewModel`. For Task 003 it handles cursor proximity/direction;
/// typing is added in a later task.
@MainActor
final class GlobalInputMonitor {
    private let cursorTracker = CursorTracker()
    private let dogViewModel: DogViewModel
    /// Current dog center in screen coordinates, or `nil` if the overlay is gone.
    private let dogCenter: () -> CGPoint?

    /// Within this distance the dog watches the cursor.
    private let nearRadius: CGFloat = 240
    /// Within this (smaller) distance the dog gets excited.
    private let excitedRadius: CGFloat = 90

    init(dogViewModel: DogViewModel, dogCenter: @escaping () -> CGPoint?) {
        self.dogViewModel = dogViewModel
        self.dogCenter = dogCenter
    }

    func start() {
        cursorTracker.onMove = { [weak self] location in
            self?.handleCursor(at: location)
        }
        cursorTracker.start()
    }

    func stop() {
        cursorTracker.stop()
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
