import AppKit

/// Composition root: constructs and retains the shared objects the app needs
/// and wires them to the overlay window. Later tasks add input and
/// productivity managers here; for the MVP scaffold it owns the dog view model,
/// settings store, and overlay controller.
@MainActor
final class AppEnvironment {
    let settingsStore: SettingsStore
    let dogViewModel: DogViewModel
    private let overlayController: DogOverlayWindowController

    init() {
        let settingsStore = SettingsStore()
        let dogViewModel = DogViewModel()

        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
        self.overlayController = DogOverlayWindowController(
            dogViewModel: dogViewModel,
            positionStore: OverlayPositionStore(defaults: settingsStore.defaults)
        )
    }

    /// Show the transparent dog overlay.
    func showOverlay() {
        overlayController.showOverlay()
    }
}
