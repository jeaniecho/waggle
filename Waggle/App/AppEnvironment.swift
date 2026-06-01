import AppKit

/// Composition root: constructs and retains the shared objects the app needs
/// and wires them to the overlay window. Later tasks add input and
/// productivity managers here; for the MVP scaffold it owns the dog view model,
/// settings store, and overlay controller.
@MainActor
final class AppEnvironment {
    let settingsStore: SettingsStore
    let dogViewModel: DogViewModel
    let permissionManager: AccessibilityPermissionManager
    private let overlayController: DogOverlayWindowController
    private let inputMonitor: GlobalInputMonitor

    init() {
        let settingsStore = SettingsStore()
        let dogViewModel = DogViewModel()
        let permissionManager = AccessibilityPermissionManager()
        let overlayController = DogOverlayWindowController(
            dogViewModel: dogViewModel,
            permissionManager: permissionManager,
            positionStore: OverlayPositionStore(defaults: settingsStore.defaults)
        )

        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
        self.permissionManager = permissionManager
        self.overlayController = overlayController
        self.inputMonitor = GlobalInputMonitor(
            dogViewModel: dogViewModel,
            permission: permissionManager,
            dogCenter: { [weak overlayController] in overlayController?.dogCenter }
        )
    }

    /// Show the transparent dog overlay and start reacting to the cursor.
    func showOverlay() {
        permissionManager.refresh()
        overlayController.showOverlay()
        inputMonitor.start()
    }
}
