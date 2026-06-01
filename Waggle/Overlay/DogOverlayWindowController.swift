import AppKit
import SwiftUI

/// Creates the overlay window, hosts the SwiftUI dog inside it, restores the
/// saved position on launch, drives the dog's `dragging` state during a drag,
/// and persists the position when the drag ends.
@MainActor
final class DogOverlayWindowController: NSWindowController {
    private let dogViewModel: DogViewModel
    private let positionStore: OverlayPositionStore

    /// The dog state to restore when a drag finishes.
    private var stateBeforeDrag: DogState?

    init(dogViewModel: DogViewModel, positionStore: OverlayPositionStore) {
        self.dogViewModel = dogViewModel
        self.positionStore = positionStore

        let contentSize = DogSpriteView.size
        let window = DogOverlayWindow(contentSize: contentSize)

        let hostingView = NSHostingView(rootView: DogOverlayView(dogViewModel: dogViewModel))
        hostingView.frame = NSRect(origin: .zero, size: contentSize)
        window.contentView = hostingView

        super.init(window: window)

        window.dragDidBegin = { [weak self] in self?.handleDragBegan() }
        window.dragDidEnd = { [weak self] in self?.handleDragEnded() }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not used")
    }

    /// Place the overlay (restoring the saved position or defaulting to a
    /// sensible spot) and show it without activating the app.
    func showOverlay() {
        guard let window else { return }

        if let origin = positionStore.loadOrigin() {
            window.setFrameOrigin(origin)
        } else {
            positionDefault(window)
        }

        window.orderFrontRegardless()
    }

    /// Default to the lower-right of the main screen's visible area.
    private func positionDefault(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let size = window.frame.size
        let origin = CGPoint(
            x: visible.maxX - size.width - 40,
            y: visible.minY + 40
        )
        window.setFrameOrigin(origin)
    }

    // MARK: - Dragging

    /// Remember the current state and switch the dog into the dragging state.
    private func handleDragBegan() {
        stateBeforeDrag = dogViewModel.state
        dogViewModel.setState(.dragging)
    }

    /// Persist the final position and restore the pre-drag state.
    private func handleDragEnded() {
        if let window {
            positionStore.saveOrigin(window.frame.origin)
        }
        dogViewModel.setState(stateBeforeDrag ?? .idle)
        stateBeforeDrag = nil
    }
}
