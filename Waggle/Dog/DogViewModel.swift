import SwiftUI

/// Observable source of truth for the dog's state and the animation derived
/// from it. SwiftUI views observe this object.
///
/// In the MVP scaffold only `idle`/`dragging` are driven; the priority-based
/// resolution described in ARCHITECTURE.md is added in later tasks.
@MainActor
final class DogViewModel: ObservableObject {
    @Published private(set) var state: DogState = .idle
    @Published private(set) var animationState: DogAnimationState = .idle

    /// Update the semantic state and recompute the matching animation state.
    func setState(_ newState: DogState) {
        guard newState != state else { return }
        state = newState
        animationState = Self.animationState(for: newState)
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
