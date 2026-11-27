import SwiftUI

@MainActor
final class DogViewModel: ObservableObject {
    @Published private(set) var state: DogState = .idle
    @Published private(set) var animationState: DogAnimationState = .idle
    @Published private(set) var keyPressCount: Int = 0
    @Published private(set) var leftEarPulse: Int = 0
    @Published private(set) var rightEarPulse: Int = 0
    @Published var coat: DogCoat = .default
    @Published private(set) var cursorAngle: Double?
    @Published var hasBone: Bool = false
    @Published private(set) var isDraggingPublished: Bool = false

    // MARK: - Input signals

    private var isDragging = false
    private var isStretching = false
    private var isBreakTime = false
    private var isFocusing = false
    private var isTyping = false
    private var isDrowsy = false
    private var isSleeping = false
    private var cursorDirection: DogDirection?
    private var cursorIsExcited = false

    // MARK: - Idle timer

    private var idleTimer: Timer?
    private var lastActivityDate = Date()

    /// Seconds of inactivity before drowsy / sleeping kicks in.
    private let drowsyAfter: TimeInterval = 180  // 3 min
    private let sleepAfter:  TimeInterval = 300  // 5 min

    func startIdleTracking() {
        idleTimer = Timer(timeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickIdle() }
        }
        RunLoop.main.add(idleTimer!, forMode: .common)
    }

    private func tickIdle() {
        let elapsed = Date().timeIntervalSince(lastActivityDate)
        let nowDrowsy  = elapsed >= drowsyAfter && elapsed < sleepAfter
        let nowSleeping = elapsed >= sleepAfter
        guard nowDrowsy != isDrowsy || nowSleeping != isSleeping else { return }
        isDrowsy  = nowDrowsy
        isSleeping = nowSleeping
        recompute()
    }

    /// Call on any user activity (typing, cursor move, click).
    func resetIdleTimer() {
        lastActivityDate = Date()
        guard isDrowsy || isSleeping else { return }
        isDrowsy = false
        isSleeping = false
        recompute()
    }

    // MARK: - Signal updates

    func setDragging(_ dragging: Bool) {
        guard isDragging != dragging else { return }
        isDragging = dragging
        isDraggingPublished = dragging
        if dragging { resetIdleTimer() }
        recompute()
    }

    func setStretching(_ stretching: Bool) {
        guard isStretching != stretching else { return }
        isStretching = stretching
        recompute()
    }

    func setFocusing(_ focusing: Bool) {
        guard isFocusing != focusing else { return }
        isFocusing = focusing
        recompute()
    }

    func setBreakTime(_ breakTime: Bool) {
        guard isBreakTime != breakTime else { return }
        isBreakTime = breakTime
        recompute()
    }

    func registerKeystroke() {
        resetIdleTimer()
        keyPressCount &+= 1
    }

    func flapLeftEar()  { leftEarPulse  &+= 1 }
    func flapRightEar() { rightEarPulse &+= 1 }

    func setTyping(_ typing: Bool) {
        if typing { resetIdleTimer() }
        guard isTyping != typing else { return }
        isTyping = typing
        recompute()
    }

    func updateCursor(direction: DogDirection?, excited: Bool, angle: Double?) {
        if cursorAngle != angle { cursorAngle = angle }
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

    private func resolveState() -> DogState {
        if isDragging   { return .dragging }
        if isStretching { return .stretching }
        if isBreakTime  { return .breakTime }
        if isFocusing   { return .focusing }
        if isTyping     { return .typing }
        if let direction = cursorDirection {
            return cursorIsExcited ? .excited : .watchingCursor(direction: direction)
        }
        if isSleeping { return .sleeping }
        if isDrowsy   { return .drowsy }
        return .idle
    }

    private static func animationState(for state: DogState) -> DogAnimationState {
        switch state {
        case .idle:             return .idle
        case .drowsy:           return .drowsy
        case .sleeping:         return .sleeping
        case .watchingCursor:   return .tailWag
        case .excited:          return .tailWag
        case .typing:           return .typing
        case .dragging:         return .dragged
        case .stretching:       return .stretch
        case .focusing:         return .sleep
        case .breakTime:        return .celebrate
        }
    }
}
