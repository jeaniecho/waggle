import Foundation

/// Persists and restores the overlay window's origin (bottom-left, in screen
/// coordinates) via UserDefaults. Position is the only window state the MVP
/// stores.
struct OverlayPositionStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    /// The saved origin, or `nil` if none has been stored yet.
    func loadOrigin() -> CGPoint? {
        guard
            defaults.object(forKey: UserDefaultsKeys.dogPositionX) != nil,
            defaults.object(forKey: UserDefaultsKeys.dogPositionY) != nil
        else {
            return nil
        }
        let x = defaults.double(forKey: UserDefaultsKeys.dogPositionX)
        let y = defaults.double(forKey: UserDefaultsKeys.dogPositionY)
        return CGPoint(x: x, y: y)
    }

    func saveOrigin(_ origin: CGPoint) {
        defaults.set(Double(origin.x), forKey: UserDefaultsKeys.dogPositionX)
        defaults.set(Double(origin.y), forKey: UserDefaultsKeys.dogPositionY)
    }
}
