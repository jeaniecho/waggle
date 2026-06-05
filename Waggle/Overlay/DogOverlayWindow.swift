import AppKit

/// Borderless, transparent, always-on-top panel that hosts the dog.
///
/// An `NSPanel` (rather than `NSWindow`) lets us use the `.nonactivatingPanel`
/// style so clicking the dog to drag it does not steal focus from the user's
/// frontmost app.
///
/// Dragging is driven manually from `mouseDown` via AppKit's native
/// `performDrag(with:)` (rather than `isMovableByWindowBackground`) so we can
/// bracket the drag with `dragDidBegin`/`dragDidEnd` callbacks and let the
/// controller drive the dog's `dragging` state.
final class DogOverlayWindow: NSPanel {
    /// Called when the user starts pressing on the dog (drag grab begins).
    var dragDidBegin: (() -> Void)?
    /// Called when the press is released (drag ends).
    var dragDidEnd: (() -> Void)?
    /// Called when the dog is left-clicked without being dragged.
    var onClick: (() -> Void)?
    /// Called when the dog is right-clicked.
    var onRightClick: (() -> Void)?

    init(contentSize: CGSize) {
        super.init(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .floating

        // Float above normal windows on every Space, including over full-screen
        // apps, without becoming a managed Space of its own.
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        // Overlay should not participate in standard window cycling / titlebar.
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isExcludedFromWindowsMenu = true
    }

    // A borderless panel returns false by default; allow key so it can receive
    // mouse-drag events reliably while still not activating the app.
    override var canBecomeKey: Bool { true }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }

    /// Perform a native window drag, bracketed by begin/end callbacks.
    /// `performDrag(with:)` runs AppKit's drag-tracking loop and returns once
    /// the user releases the mouse, giving smooth movement with no coordinate
    /// feedback issues.
    override func mouseDown(with event: NSEvent) {
        let before = frame.origin
        dragDidBegin?()
        performDrag(with: event)
        dragDidEnd?()
        // If the window didn't actually move, treat it as a click (not a drag).
        if hypot(frame.origin.x - before.x, frame.origin.y - before.y) < 3 {
            onClick?()
        }
    }
}
