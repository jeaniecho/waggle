import AppKit

/// Borderless, transparent, always-on-top panel that hosts the dog.
///
/// An `NSPanel` (rather than `NSWindow`) lets us use the `.nonactivatingPanel`
/// style so clicking the dog to drag it does not steal focus from the user's
/// frontmost app. Dragging is provided by `isMovableByWindowBackground`, set by
/// the controller.
final class DogOverlayWindow: NSPanel {
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
        isMovableByWindowBackground = true

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
}
