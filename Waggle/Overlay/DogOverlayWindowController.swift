import AppKit
import SwiftUI

/// Creates the overlay window, hosts the SwiftUI dog inside it, restores the
/// saved position on launch, drives the dog's `dragging` state during a drag,
/// and persists the position when the drag ends.
@MainActor
final class DogOverlayWindowController: NSWindowController {
    private let dogViewModel: DogViewModel
    private let positionStore: OverlayPositionStore

    // Roaming (break time): the dog runs back and forth across the screen.
    private var roamTimer: Timer?
    private var roamHome: CGPoint?
    private var roamDirection: CGFloat = 1
    private var roamPhase: CGFloat = 0
    private let roamSpeed: CGFloat = 7   // points per tick (~60 fps)
    private let roamHop: CGFloat = 16    // bounce height while running

    /// Current dog center in screen coordinates, for cursor-proximity checks.
    var dogCenter: CGPoint? {
        guard let window else { return nil }
        return CGPoint(x: window.frame.midX, y: window.frame.midY)
    }

    init(
        dogViewModel: DogViewModel,
        permissionManager: AccessibilityPermissionManager,
        stretchManager: StretchReminderManager,
        pomodoroManager: PomodoroManager,
        positionStore: OverlayPositionStore
    ) {
        self.dogViewModel = dogViewModel
        self.positionStore = positionStore

        let contentSize = DogSpriteView.size
        let window = DogOverlayWindow(contentSize: contentSize)

        let hostingView = NSHostingView(
            rootView: DogOverlayView(
                dogViewModel: dogViewModel,
                permission: permissionManager,
                stretch: stretchManager,
                pomodoro: pomodoroManager
            )
        )
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

    /// Whether the overlay is currently on screen.
    var isOverlayVisible: Bool {
        window?.isVisible ?? false
    }

    /// Show or hide the overlay without activating the app.
    func setVisible(_ visible: Bool) {
        guard let window else { return }
        if visible {
            window.orderFrontRegardless()
        } else {
            window.orderOut(nil)
        }
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

    // MARK: - Roaming (break time)

    /// Start running the dog back and forth across the screen, hopping as it
    /// goes. Remembers where it started so it can return there afterwards.
    func startRoaming() {
        guard roamTimer == nil, let window else { return }
        roamHome = window.frame.origin
        roamPhase = 0
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.roamStep() }
        }
        // Keep running while menus/tracking loops are active.
        RunLoop.main.add(timer, forMode: .common)
        roamTimer = timer
    }

    /// Stop running and return the dog to where it started.
    func stopRoaming() {
        guard roamTimer != nil else { return }
        roamTimer?.invalidate()
        roamTimer = nil
        if let window, let home = roamHome {
            window.setFrameOrigin(home)
        }
        roamHome = nil
    }

    private func roamStep() {
        guard let window, let home = roamHome else { return }
        let visible = (window.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        let width = window.frame.width

        var x = window.frame.origin.x + roamDirection * roamSpeed
        if x <= visible.minX {
            x = visible.minX
            roamDirection = 1
        } else if x + width >= visible.maxX {
            x = visible.maxX - width
            roamDirection = -1
        }

        roamPhase += 0.28
        let y = home.y + abs(sin(roamPhase)) * roamHop // little hops
        window.setFrameOrigin(CGPoint(x: x, y: y))
    }

    // MARK: - Dragging

    /// Switch the dog into the dragging state (highest priority).
    private func handleDragBegan() {
        dogViewModel.setDragging(true)
    }

    /// Persist the final position; the view model resolves back to the
    /// cursor/idle state once dragging clears.
    private func handleDragEnded() {
        if let window {
            positionStore.saveOrigin(window.frame.origin)
        }
        dogViewModel.setDragging(false)
    }
}
