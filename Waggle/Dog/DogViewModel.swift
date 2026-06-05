import SwiftUI

/// Observable source of truth for the dog's state and the animation derived
/// from it. SwiftUI views observe this object.
///
/// Rather than letting callers set `state` directly (which would let competing
/// inputs stomp on each other), the view model stores the individual input
/// *signals* and resolves the visible `state` by priority — see ARCHITECTURE.md
/// and docs/specs/DOG_STATE_MACHINE.md. Later tasks add more signals (typing,
/// stretch, Pomodoro) into `resolveState()` at the appropriate priority.
@MainActor
final class DogViewModel: ObservableObject {
    @Published private(set) var state: DogState = .idle
    @Published private(set) var animationState: DogAnimationState = .idle
    /// Increments once per detected keystroke. Views observe changes to pulse a
    /// per-key reaction (e.g. an ear flap); it carries no key content (privacy).
    @Published private(set) var keyPressCount: Int = 0
    /// Increments on left-click; flaps the left ear.
    @Published private(set) var leftEarPulse: Int = 0
    /// Increments on right-click; flaps the right ear.
    @Published private(set) var rightEarPulse: Int = 0
    /// Increments when a "?" is typed, so the dog can tilt its head. Only the
    /// fact that "?" was pressed is kept — never the surrounding text.
    @Published private(set) var headTiltCount: Int = 0
    /// Increments when a "!" is typed, so the dog can jump. As with "?", only the
    /// fact that "!" was pressed is kept.
    @Published private(set) var jumpCount: Int = 0
    /// The dog's coat colour (set from settings / the menu bar).
    @Published var coat: DogCoat = .default
    /// Angle to the cursor while nearby, in degrees (atan2(dy, dx), screen
    /// coords), so the tail can point toward it in any direction. `nil` if far.
    @Published private(set) var cursorAngle: Double?
    /// Whether the dog is currently carrying a fetched bone.
    @Published var hasBone: Bool = false

    // MARK: - Input signals

    /// Published so views can directly suppress cursor-follow during drag.
    @Published private(set) var isDraggingPublished: Bool = false
    private var isDragging = false
    private var isStretching = false
    private var isBreakTime = false
    private var isFocusing = false
    private var isTyping = false
    /// Direction to the cursor while it is nearby; `nil` when the cursor is far.
    private var cursorDirection: DogDirection?
    /// Cursor is close enough to excite the dog.
    private var cursorIsExcited = false

    // MARK: - Signal updates

    /// Set by the overlay while the user is dragging the dog.
    func setDragging(_ dragging: Bool) {
        guard isDragging != dragging else { return }
        isDragging = dragging
        isDraggingPublished = dragging
        recompute()
    }

    /// Set by the stretch reminder while a stretch nudge is active.
    func setStretching(_ stretching: Bool) {
        guard isStretching != stretching else { return }
        isStretching = stretching
        recompute()
    }

    /// Set by the Pomodoro manager during a focus interval.
    func setFocusing(_ focusing: Bool) {
        guard isFocusing != focusing else { return }
        isFocusing = focusing
        recompute()
    }

    /// Set by the Pomodoro manager during a break interval.
    func setBreakTime(_ breakTime: Bool) {
        guard isBreakTime != breakTime else { return }
        isBreakTime = breakTime
        recompute()
    }

    /// Called once per keystroke to drive per-key reactions.
    func registerKeystroke() {
        keyPressCount &+= 1
    }

    func flapLeftEar()  { leftEarPulse  &+= 1 }
    func flapRightEar() { rightEarPulse &+= 1 }

    /// Called when a "?" is typed, to trigger the head-tilt reaction.
    func registerQuestionMark() {
        headTiltCount &+= 1
    }

    /// Called when a "!" is typed, to trigger the jump reaction.
    func registerExclamation() {
        jumpCount &+= 1
    }

    /// Set (debounced) by the typing tracker while the user is typing.
    func setTyping(_ typing: Bool) {
        guard isTyping != typing else { return }
        isTyping = typing
        recompute()
    }

    /// Update cursor proximity. Pass `direction: nil`/`lean: nil` when the cursor
    /// is far; `excited: true` when very close. `lean` is the horizontal
    /// direction to the cursor (-1…+1) for the tail to follow.
    func updateCursor(direction: DogDirection?, excited: Bool, angle: Double?) {
        if cursorAngle != angle { cursorAngle = angle } // continuous; no state recompute
        guard cursorDirection != direction || cursorIsExcited != excited else { return }
        cursorDirection = direction
        cursorIsExcited = excited
        recompute()
    }

    // MARK: - Resolution

    private func recompute() {
        let newState = resolveState()
        guard newState != state else { return }
        state = newState
        animationState = Self.animationState(for: newState)
    }

    /// Resolve the visible state from current signals, highest priority first.
    private func resolveState() -> DogState {
        if isDragging { return .dragging }
        if isStretching { return .stretching }
        if isBreakTime { return .breakTime }
        if isFocusing { return .focusing }
        if isTyping { return .typing }
        if let direction = cursorDirection {
            return cursorIsExcited ? .excited : .watchingCursor(direction: direction)
        }
        return .idle
    }

    private static func animationState(for state: DogState) -> DogAnimationState {
        switch state {
        case .idle: return .idle
        case .watchingCursor: return .tailWag
        case .excited: return .tailWag
        case .typing: return .typing
        case .dragging: return .dragged
        case .stretching: return .stretch
        case .focusing: return .sleep
        case .breakTime: return .celebrate
        }
    }
}
