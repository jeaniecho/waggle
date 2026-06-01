import Foundation

/// Thin wrapper over UserDefaults for app settings. Exposes the underlying
/// `defaults` so collaborators (e.g. `OverlayPositionStore`) can share the same
/// store. Settings read/write helpers are filled in by the productivity tasks.
final class SettingsStore {
    let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}
