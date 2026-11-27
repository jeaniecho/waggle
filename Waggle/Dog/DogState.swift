import Foundation

/// Semantic dog state — *what the dog is doing*, independent of how it looks.
///
/// State transitions are resolved by priority (see ARCHITECTURE.md). Only
/// All competing signals are resolved by `DogViewModel` before rendering.
enum DogState: Equatable {
    case idle
    case drowsy
    case sleeping
    case watchingCursor(direction: DogDirection)
    case excited
    case typing
    case dragging
    case stretching
    case focusing
    case breakTime
}
