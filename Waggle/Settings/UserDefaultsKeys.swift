import Foundation

/// Centralized UserDefaults key strings so they are defined exactly once.
/// Only keys needed by the current milestone are populated; the rest are
/// declared so later tasks reference a single source of truth.
enum UserDefaultsKeys {
    static let dogPositionX = "dog.position.x"
    static let dogPositionY = "dog.position.y"

    static let stretchEnabled = "stretch.enabled"
    static let stretchIntervalMinutes = "stretch.intervalMinutes"

    static let pomodoroFocusMinutes = "pomodoro.focusMinutes"
    static let pomodoroBreakMinutes = "pomodoro.breakMinutes"

    static let dogCoat = "dog.coat"
}
