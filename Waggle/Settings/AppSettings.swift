import Foundation

/// Plain value type describing user-configurable settings and their defaults.
/// Productivity tasks read/write this through `SettingsStore`; the scaffold
/// only defines the shape and defaults.
struct AppSettings: Equatable {
    var stretchEnabled: Bool
    var stretchIntervalMinutes: Int
    var pomodoroFocusMinutes: Int
    var pomodoroBreakMinutes: Int

    static let defaults = AppSettings(
        stretchEnabled: true,
        stretchIntervalMinutes: 45,
        pomodoroFocusMinutes: 25,
        pomodoroBreakMinutes: 5
    )
}
