import Foundation

/// Visual animation state — *how the dog looks*. Derived from `DogState` by the
/// view model so rendering concerns stay separate from semantic state.
enum DogAnimationState: Equatable {
    case idle
    case drowsy
    case sleeping
    case tailWag
    case blink
    case typing
    case dragged
    case stretch
    case sleep
    case celebrate
}
