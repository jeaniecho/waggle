import Foundation

/// Actions the menu bar will expose (Task 008). Declared now so the menu-bar
/// task only needs to wire them up.
enum MenuBarAction: Equatable {
    case startPomodoro
    case stopPomodoro
    case resetStretchTimer
    case showWaggle
    case hideWaggle
    case openAccessibilitySettings
    case quit
}
