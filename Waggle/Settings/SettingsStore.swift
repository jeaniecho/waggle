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
}
