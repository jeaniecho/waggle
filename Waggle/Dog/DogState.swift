import Foundation

/// Semantic dog state — *what the dog is doing*, independent of how it looks.
///
/// State transitions are resolved by priority (see ARCHITECTURE.md). Only
/// `idle` and `dragging` are exercised in the MVP scaffold; the remaining
/// cases exist so later tasks can fill them in without changing this type.
enum DogState: Equatable {
    case idle
    case watchingCursor(direction: DogDirection)
    case excited
    case typing
    case dragging
    case stretching
    case focusing
    case breakTime
}
