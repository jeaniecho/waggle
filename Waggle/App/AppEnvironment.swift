import AppKit
import Combine

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
    let pomodoroManager: PomodoroManager
    private let overlayController: DogOverlayWindowController
    private let inputMonitor: GlobalInputMonitor
    private var menuBarController: MenuBarController?
    private var breakCancellable: AnyCancellable?

    init() {
        let settingsStore = SettingsStore()
        let dogViewModel = DogViewModel()
        let permissionManager = AccessibilityPermissionManager()
        let stretchManager = StretchReminderManager(
            settingsStore: settingsStore,
            dogViewModel: dogViewModel
        )
        let pomodoroManager = PomodoroManager(
            settingsStore: settingsStore,
            dogViewModel: dogViewModel
        )
        let overlayController = DogOverlayWindowController(
            dogViewModel: dogViewModel,
            permissionManager: permissionManager,
            stretchManager: stretchManager,
            pomodoroManager: pomodoroManager,
            positionStore: OverlayPositionStore(defaults: settingsStore.defaults)
        )

        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
        self.permissionManager = permissionManager
        self.stretchManager = stretchManager
        self.pomodoroManager = pomodoroManager
        self.overlayController = overlayController
        self.inputMonitor = GlobalInputMonitor(
            dogViewModel: dogViewModel,
            permission: permissionManager,
            dogCenter: { [weak overlayController] in overlayController?.dogCenter }
        )
    }

    /// Show the transparent dog overlay, start reacting to input, begin the
    /// stretch reminder countdown, and install the menu bar.
    func showOverlay() {
        permissionManager.refresh()
        overlayController.showOverlay()
        inputMonitor.start()
        stretchManager.start()
        installMenuBar()
        observeBreak()
    }

    /// Run the dog across the screen during Pomodoro breaks; return it home when
    /// the break ends.
    private func observeBreak() {
        breakCancellable = pomodoroManager.$state
            .map { state -> Bool in
                if case .breakTime = state { return true }
                return false
            }
            .removeDuplicates()
            .sink { [weak self] isBreak in
                if isBreak {
                    self?.overlayController.startRoaming()
                } else {
                    self?.overlayController.stopRoaming()
                }
            }
    }

    private func installMenuBar() {
        menuBarController = MenuBarController(
            onAction: { [weak self] action in self?.handle(action) },
            isPomodoroActive: { [weak self] in self?.pomodoroManager.isActive ?? false },
            isOverlayVisible: { [weak self] in self?.overlayController.isOverlayVisible ?? false }
        )
    }

    /// Route a menu action to the owning manager. The menu bar holds no logic of
    /// its own — every case delegates to an existing manager method.
    private func handle(_ action: MenuBarAction) {
        switch action {
        case .startPomodoro: pomodoroManager.start()
        case .stopPomodoro: pomodoroManager.stop()
        case .resetStretchTimer: stretchManager.reset()
        case .showWaggle: overlayController.setVisible(true)
        case .hideWaggle: overlayController.setVisible(false)
        case .openAccessibilitySettings: permissionManager.promptForAccessibility()
        case .quit: NSApplication.shared.terminate(nil)
        }
    }
}
