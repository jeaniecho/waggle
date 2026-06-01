import AppKit
import SwiftUI

/// Creates the overlay window, hosts the SwiftUI dog inside it, restores the
/// saved position on launch, and persists the position whenever the user
/// finishes dragging the dog.
@MainActor
final class DogOverlayWindowController: NSWindowController, NSWindowDelegate {
    private let dogViewModel: DogViewModel
    private let positionStore: OverlayPositionStore

    init(dogViewModel: DogViewModel, positionStore: OverlayPositionStore) {
        self.dogViewModel = dogViewModel
        self.positionStore = positionStore

        let contentSize = DogSpriteView.size
        let window = DogOverlayWindow(contentSize: contentSize)

        let hostingView = NSHostingView(rootView: DogOverlayView(dogViewModel: dogViewModel))
        hostingView.frame = NSRect(origin: .zero, size: contentSize)
        window.contentView = hostingView

        super.init(window: window)
        window.delegate = self
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

    // MARK: - NSWindowDelegate

    /// Persist the new position after each move (drag). Cheap enough to write
    /// directly; debouncing can be added if it ever proves chatty.
    func windowDidMove(_ notification: Notification) {
        guard let window else { return }
        positionStore.saveOrigin(window.frame.origin)
    }
}
