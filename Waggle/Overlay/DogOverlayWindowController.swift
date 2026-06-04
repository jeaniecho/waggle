import AppKit
import SwiftUI

/// Creates the overlay window, hosts the SwiftUI dog inside it, restores the
/// saved position on launch, drives the dog's `dragging` state during a drag,
/// and persists the position when the drag ends.
@MainActor
final class DogOverlayWindowController: NSWindowController {
    private let dogViewModel: DogViewModel
    private let positionStore: OverlayPositionStore

    // Roaming (break time): the dog strolls slowly to random points all over
    // the screen, with a gentle walking bob.
    private var roamTimer: Timer?
    private var roamPos: CGPoint = .zero // base walking position (without the bob)
    private var roamTarget: CGPoint?     // current destination
    private var roamPhase: CGFloat = 0
    private let roamSpeed: CGFloat = 1.5 // points per tick (~60 fps) — slow stroll
    private let roamHop: CGFloat = 10    // gentle walking bob
    private let roamHopRate: CGFloat = 0.1 // smaller = longer interval between hops

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

    /// Start strolling the dog slowly to random spots across the screen.
    /// Remembers where it started so it can return there afterwards.
    func startRoaming() {
        guard roamTimer == nil, let window else { return }
        roamPos = window.frame.origin
        roamTarget = randomRoamTarget()
        roamPhase = 0
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.roamStep() }
        }
        // Keep running while menus/tracking loops are active.
        RunLoop.main.add(timer, forMode: .common)
        roamTimer = timer
    }

    /// Stop strolling and stay wherever the dog ended up (settling out of the
    /// hop), remembering that spot as the new saved position.
    func stopRoaming() {
        guard roamTimer != nil else { return }
        roamTimer?.invalidate()
        roamTimer = nil
        if let window {
            window.setFrameOrigin(roamPos)
            positionStore.saveOrigin(roamPos)
        }
        roamTarget = nil
    }

    /// A random reachable origin anywhere on the current screen's visible area.
    private func randomRoamTarget() -> CGPoint {
        guard let window else { return .zero }
        let visible = (window.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        let maxX = max(visible.minX, visible.maxX - window.frame.width)
        let maxY = max(visible.minY, visible.maxY - window.frame.height)
        return CGPoint(
            x: .random(in: visible.minX ... maxX),
            y: .random(in: visible.minY ... maxY)
        )
    }

    private func roamStep() {
        guard let window else { return }
        let target = roamTarget ?? randomRoamTarget()

        let dx = target.x - roamPos.x
        let dy = target.y - roamPos.y
        let dist = max(0.0001, (dx * dx + dy * dy).squareRoot())
        if dist <= roamSpeed {
            roamPos = target
            roamTarget = randomRoamTarget() // arrived → pick a new spot
        } else {
            roamPos.x += dx / dist * roamSpeed
            roamPos.y += dy / dist * roamSpeed
        }

        roamPhase += roamHopRate
        let hop = abs(sin(roamPhase)) * roamHop // gentle walking bob
        window.setFrameOrigin(CGPoint(x: roamPos.x, y: roamPos.y + hop))
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
