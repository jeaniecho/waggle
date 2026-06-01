import Foundation

/// Generic, privacy-preserving input signal published by the input layer.
///
/// Per PRIVACY.md, Waggle never records key names, text, app names, or cursor
/// paths — only that *some* input happened. Cursor movement carries a global
/// screen location so the dog can face the cursor, but is not stored.
enum InputEvent: Equatable {
    case cursorMoved(location: CGPoint)
    case keyPressed
}
