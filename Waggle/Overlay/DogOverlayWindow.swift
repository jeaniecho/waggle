import AppKit

/// Borderless, transparent, always-on-top panel that hosts the dog.
///
/// Dragging uses `mouseDragged`/`mouseUp` instead of `performDrag(with:)` so
/// the main RunLoop stays free and SwiftUI's rendering pipeline runs normally
/// during the drag (e.g. tail-spin animation).
final class DogOverlayWindow: NSPanel {
    var dragDidBegin: (() -> Void)?
    var dragDidEnd: (() -> Void)?
    var onClick: (() -> Void)?
    var onRightClick: (() -> Void)?

    private var dragStartMouse: CGPoint = .zero
    private var dragStartOrigin: CGPoint = .zero
    private var hasMoved = false

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

        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isExcludedFromWindowsMenu = true
    }

    override var canBecomeKey: Bool { true }

    override func mouseDown(with event: NSEvent) {
        dragStartMouse = NSEvent.mouseLocation
        dragStartOrigin = frame.origin
        hasMoved = false
        dragDidBegin?()
    }

    override func mouseDragged(with event: NSEvent) {
        hasMoved = true
        let loc = NSEvent.mouseLocation
        setFrameOrigin(CGPoint(
            x: dragStartOrigin.x + loc.x - dragStartMouse.x,
            y: dragStartOrigin.y + loc.y - dragStartMouse.y
        ))
    }

    override func mouseUp(with event: NSEvent) {
        dragDidEnd?()
        if !hasMoved { onClick?() }
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }
}
