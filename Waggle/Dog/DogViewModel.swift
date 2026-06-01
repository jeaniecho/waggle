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

    // MARK: - Input signals

    private var isDragging = false
    /// Direction to the cursor while it is nearby; `nil` when the cursor is far.
    private var cursorDirection: DogDirection?
    /// Cursor is close enough to excite the dog.
    private var cursorIsExcited = false

    // MARK: - Signal updates

    /// Set by the overlay while the user is dragging the dog.
    func setDragging(_ dragging: Bool) {
        guard isDragging != dragging else { return }
        isDragging = dragging
        recompute()
    }

    /// Update cursor proximity. Pass `direction: nil` when the cursor is far
    /// away; pass `excited: true` when it is very close.
    func updateCursor(direction: DogDirection?, excited: Bool) {
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
