import Foundation

/// Plain value type describing user-configurable settings and their defaults.
/// Productivity tasks read/write this through `SettingsStore`; the scaffold
/// only defines the shape and defaults.
struct AppSettings: Equatable {
    var stretchEnabled: Bool
    var stretchIntervalMinutes: Int
    var pomodoroFocusMinutes: Int
    var pomodoroBreakMinutes: Int
    var pomodoroLongBreakMinutes: Int
    var pomodoroSessionsBeforeLongBreak: Int
    var dogCoatID: String
    var reactCursor: Bool
    var reactTyping: Bool
    var reactionsPaused: Bool
    var notificationsEnabled: Bool

    static let defaults = AppSettings(
        stretchEnabled: true,
        stretchIntervalMinutes: 45,
        pomodoroFocusMinutes: 25,
        pomodoroBreakMinutes: 5,
        pomodoroLongBreakMinutes: 15,
        pomodoroSessionsBeforeLongBreak: 4,
        dogCoatID: "tan",
        reactCursor: true,
        reactTyping: true,
        reactionsPaused: false,
        notificationsEnabled: true
    )
}
