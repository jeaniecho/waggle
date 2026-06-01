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
    let stretchManager: StretchReminderManager
    private let overlayController: DogOverlayWindowController
    private let inputMonitor: GlobalInputMonitor

    init() {
        let settingsStore = SettingsStore()
        let dogViewModel = DogViewModel()
        let permissionManager = AccessibilityPermissionManager()
        let stretchManager = StretchReminderManager(
            settingsStore: settingsStore,
            dogViewModel: dogViewModel
        )
        let overlayController = DogOverlayWindowController(
            dogViewModel: dogViewModel,
            permissionManager: permissionManager,
            stretchManager: stretchManager,
            positionStore: OverlayPositionStore(defaults: settingsStore.defaults)
        )

        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
        self.permissionManager = permissionManager
        self.stretchManager = stretchManager
        self.overlayController = overlayController
        self.inputMonitor = GlobalInputMonitor(
            dogViewModel: dogViewModel,
            permission: permissionManager,
            dogCenter: { [weak overlayController] in overlayController?.dogCenter }
        )
    }

    /// Show the transparent dog overlay, start reacting to input, and begin the
    /// stretch reminder countdown.
    func showOverlay() {
        permissionManager.refresh()
        overlayController.showOverlay()
        inputMonitor.start()
        stretchManager.start()
    }
}
