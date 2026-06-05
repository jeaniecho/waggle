import AppKit
import SwiftUI

/// Creates the overlay window, hosts the SwiftUI dog inside it, restores the
/// saved position on launch, drives the dog's `dragging` state during a drag,
/// and persists the position when the drag ends.
@MainActor
final class DogOverlayWindowController: NSWindowController {
    private let dogViewModel: DogViewModel
    private let positionStore: OverlayPositionStore

    /// Called when the dog is left-clicked (not dragged).
    var onDogClicked: (() -> Void)?
    /// Called when the dog is right-clicked.
    var onDogRightClicked: (() -> Void)?

    // Fetch: hop toward a random off-screen exit, wait, return from opposite side.
    private enum FetchPhase { case idle, wandering, away, returning }
    private enum FetchEdge { case left, right, top }
    private var fetchPhase: FetchPhase = .idle
    private var fetchTimer: Timer?
    private var fetchHome: CGPoint = .zero
    private var fetchVisible: NSRect = .zero
    private var fetchAwayUntil: Date?
    private var fetchOnReturn: (() -> Void)?
    private var fetchExitEdge: FetchEdge = .right
    private var fetchWanderTarget: CGPoint = .zero // off-screen exit point
    private var fetchWanderPos: CGPoint = .zero    // base position (without hop)
    private var fetchWanderPhase: CGFloat = 0
    private let fetchWanderSpeed: CGFloat = 2.5
    private let fetchWanderHop: CGFloat = 10

    var isFetching: Bool { fetchPhase != .idle }

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
        window.onClick = { [weak self] in self?.onDogClicked?() }
        window.onRightClick = { [weak self] in self?.onDogRightClicked?() }
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
        guard roamTimer == nil, fetchPhase == .idle, let window else { return }
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

    // MARK: - Fetch

    /// Run the dog off the right edge, pause off-screen, then run back in from
    /// the left. `onReturn` fires as it reappears (so the bone shows up then).
    func performFetch(onReturn: @escaping () -> Void) {
        guard fetchPhase == .idle, roamTimer == nil, let window else { return }
        fetchHome = window.frame.origin
        fetchVisible = (window.screen ?? NSScreen.main)?.visibleFrame ?? .zero
        fetchOnReturn = onReturn

        let w = window.frame.width, h = window.frame.height
        let v = fetchVisible

        // Pick a random edge and aim for a point just beyond it.
        let edge = [FetchEdge.left, .right, .top].randomElement() ?? .right
        fetchExitEdge = edge
        switch edge {
        case .right:
            fetchWanderTarget = CGPoint(
                x: v.maxX + w + 20,
                y: CGFloat.random(in: v.minY + 40 ... max(v.minY + 40, v.maxY - h - 40))
            )
        case .left:
            fetchWanderTarget = CGPoint(
                x: v.minX - w - 20,
                y: CGFloat.random(in: v.minY + 40 ... max(v.minY + 40, v.maxY - h - 40))
            )
        case .top:
            fetchWanderTarget = CGPoint(
                x: CGFloat.random(in: v.minX + 40 ... max(v.minX + 40, v.maxX - w - 40)),
                y: v.maxY + h + 20
            )
        }

        fetchWanderPos = window.frame.origin
        fetchWanderPhase = 0
        fetchPhase = .wandering

        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.fetchStep() }
        }
        RunLoop.main.add(timer, forMode: .common)
        fetchTimer = timer
    }

    private func fetchStep() {
        guard let window else { return }
        let w = window.frame.width, h = window.frame.height

        switch fetchPhase {
        case .wandering:
            // Hop toward the off-screen exit; switch to away once fully off-screen.
            let dx = fetchWanderTarget.x - fetchWanderPos.x
            let dy = fetchWanderTarget.y - fetchWanderPos.y
            let dist = max(0.0001, (dx * dx + dy * dy).squareRoot())
            fetchWanderPos.x += (dx / dist) * fetchWanderSpeed
            fetchWanderPos.y += (dy / dist) * fetchWanderSpeed
            fetchWanderPhase += roamHopRate
            let hop = abs(sin(fetchWanderPhase)) * fetchWanderHop
            window.setFrameOrigin(CGPoint(x: fetchWanderPos.x, y: fetchWanderPos.y + hop))

            // Fully off-screen → go away.
            let pos = fetchWanderPos
            let offScreen: Bool
            switch fetchExitEdge {
            case .right:  offScreen = pos.x > fetchVisible.maxX
            case .left:   offScreen = pos.x + w < fetchVisible.minX
            case .top:    offScreen = pos.y > fetchVisible.maxY
            }
            if offScreen {
                fetchPhase = .away
                fetchAwayUntil = Date().addingTimeInterval(2.0)
            }

        case .away:
            if let until = fetchAwayUntil, Date() >= until {
                // Reappear from opposite edge, walk back home.
                let returnOrigin: CGPoint
                switch fetchExitEdge {
                case .right:  returnOrigin = CGPoint(x: fetchVisible.minX - w - 20, y: fetchHome.y)
                case .left:   returnOrigin = CGPoint(x: fetchVisible.maxX + 20, y: fetchHome.y)
                case .top:    returnOrigin = CGPoint(x: fetchHome.x, y: fetchVisible.minY - h - 20)
                }
                fetchWanderPos = returnOrigin
                fetchWanderPhase = 0
                window.setFrameOrigin(returnOrigin)
                fetchPhase = .returning
                fetchOnReturn?()
                fetchOnReturn = nil
            }

        case .returning:
            // Hop back toward home.
            let dx = fetchHome.x - fetchWanderPos.x
            let dy = fetchHome.y - fetchWanderPos.y
            let dist = max(0.0001, (dx * dx + dy * dy).squareRoot())
            if dist < fetchWanderSpeed * 2 {
                window.setFrameOrigin(fetchHome)
                endFetch()
            } else {
                fetchWanderPos.x += (dx / dist) * fetchWanderSpeed
                fetchWanderPos.y += (dy / dist) * fetchWanderSpeed
                fetchWanderPhase += roamHopRate
                let hop = abs(sin(fetchWanderPhase)) * fetchWanderHop
                window.setFrameOrigin(CGPoint(x: fetchWanderPos.x, y: fetchWanderPos.y + hop))
            }

        case .idle:
            break
        }
    }

    private func endFetch() {
        fetchTimer?.invalidate()
        fetchTimer = nil
        fetchPhase = .idle
        fetchAwayUntil = nil
        fetchOnReturn = nil
        fetchWanderTarget = .zero
        fetchWanderPos = .zero
        fetchWanderPhase = 0
        fetchExitEdge = .right
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
