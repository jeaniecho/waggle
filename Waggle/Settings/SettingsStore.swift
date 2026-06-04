import Foundation

/// Thin wrapper over UserDefaults for app settings. Exposes the underlying
/// `defaults` so collaborators (e.g. `OverlayPositionStore`) can share the same
/// store. Each setting falls back to `AppSettings.defaults` when unset.
final class SettingsStore {
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Stretch reminder

    var stretchEnabled: Bool {
        get { defaults.object(forKey: UserDefaultsKeys.stretchEnabled) as? Bool
            ?? AppSettings.defaults.stretchEnabled }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.stretchEnabled) }
    }

    var stretchIntervalMinutes: Int {
        get {
            let stored = defaults.integer(forKey: UserDefaultsKeys.stretchIntervalMinutes)
            return stored > 0 ? stored : AppSettings.defaults.stretchIntervalMinutes
        }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.stretchIntervalMinutes) }
    }

    // MARK: - Pomodoro

    var pomodoroFocusMinutes: Int {
        get {
            let stored = defaults.integer(forKey: UserDefaultsKeys.pomodoroFocusMinutes)
            return stored > 0 ? stored : AppSettings.defaults.pomodoroFocusMinutes
        }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.pomodoroFocusMinutes) }
    }

    var pomodoroBreakMinutes: Int {
        get {
            let stored = defaults.integer(forKey: UserDefaultsKeys.pomodoroBreakMinutes)
            return stored > 0 ? stored : AppSettings.defaults.pomodoroBreakMinutes
        }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.pomodoroBreakMinutes) }
    }

    var pomodoroLongBreakMinutes: Int {
        get {
            let stored = defaults.integer(forKey: UserDefaultsKeys.pomodoroLongBreakMinutes)
            return stored > 0 ? stored : AppSettings.defaults.pomodoroLongBreakMinutes
        }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.pomodoroLongBreakMinutes) }
    }

    var pomodoroSessionsBeforeLongBreak: Int {
        get {
            let stored = defaults.integer(forKey: UserDefaultsKeys.pomodoroSessionsBeforeLongBreak)
            return stored > 0 ? stored : AppSettings.defaults.pomodoroSessionsBeforeLongBreak
        }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.pomodoroSessionsBeforeLongBreak) }
    }

    // MARK: - Reactions

    private func bool(_ key: String, default def: Bool) -> Bool {
        defaults.object(forKey: key) as? Bool ?? def
    }

    var reactCursor: Bool {
        get { bool(UserDefaultsKeys.reactCursor, default: AppSettings.defaults.reactCursor) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.reactCursor) }
    }

    var reactTyping: Bool {
        get { bool(UserDefaultsKeys.reactTyping, default: AppSettings.defaults.reactTyping) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.reactTyping) }
    }

    var reactionsPaused: Bool {
        get { bool(UserDefaultsKeys.reactionsPaused, default: AppSettings.defaults.reactionsPaused) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.reactionsPaused) }
    }

    var notificationsEnabled: Bool {
        get { bool(UserDefaultsKeys.notificationsEnabled, default: AppSettings.defaults.notificationsEnabled) }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.notificationsEnabled) }
    }

    // MARK: - Appearance

    var dogCoatID: String {
        get { defaults.string(forKey: UserDefaultsKeys.dogCoat) ?? AppSettings.defaults.dogCoatID }
        set { defaults.set(newValue, forKey: UserDefaultsKeys.dogCoat) }
    }
}
