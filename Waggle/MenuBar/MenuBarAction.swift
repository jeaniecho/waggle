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
    case setDogCoat(String)
    case setFocusMinutes(Int)
    case setBreakMinutes(Int)
    case setStretchMinutes(Int) // 0 = off
    case setReactionsPaused(Bool)
    case setReactCursor(Bool)
    case setReactTyping(Bool)
    case setNotificationsEnabled(Bool)
    case setLongBreakMinutes(Int)
    case setSessionsBeforeLongBreak(Int)
    case setLaunchAtLogin(Bool)
    case openSettings
    case quit
}
