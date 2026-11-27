import AppKit
import Combine
import SwiftUI

/// Composition root: constructs and retains the shared objects the app needs,
/// wires them to the overlay, and routes menu/settings actions to their owners.
@MainActor
final class AppEnvironment: ObservableObject {
    let settingsStore: SettingsStore
    let dogViewModel: DogViewModel
    let permissionManager: AccessibilityPermissionManager
    let stretchManager: StretchReminderManager
    let pomodoroManager: PomodoroManager
    let launchItem = LoginItemManager()
    private let notificationManager = NotificationManager()
    private let overlayController: DogOverlayWindowController
    private let inputMonitor: GlobalInputMonitor
    private var menuBarController: MenuBarController?
    private var breakCancellable: AnyCancellable?
    private var stretchNotifyCancellable: AnyCancellable?
    private var onboardingWindow: NSWindow?
    private var settingsWindowController: SettingsWindowController?
    private var fetchScheduleTimer: Timer?
    private var boneTimer: Timer?

    init() {
        let settingsStore = SettingsStore()
        let dogViewModel = DogViewModel()
        dogViewModel.coat = DogCoat.coat(id: settingsStore.dogCoatID)
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
        // Clicking the dog dismisses a stretch nudge (regardless of Pomodoro
        // state) and returns it to normal.
        overlayController.onDogClicked = { [weak self] in
            guard let self, self.stretchManager.isStretchDue else { return }
            self.stretchManager.reset()
        }
        overlayController.showOverlay()
        applyInputReactions()
        inputMonitor.start()
        if settingsStore.reactionsPaused {
            stretchManager.suspend()
        } else {
            stretchManager.start()
        }
        installMenuBar()
        observeRoaming()
        notificationManager.requestAuthorization()
        observeNotifications()
        showOnboardingIfNeeded()
        scheduleNextFetch()
    }

    // MARK: - Fetch a bone

    private func scheduleNextFetch() {
        let delay = Double.random(in: 360 ... 900) // every 6–15 minutes
        fetchScheduleTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.autoFetch()
                self?.scheduleNextFetch()
            }
        }
    }

    /// Auto fetch only when the dog isn't busy.
    private func autoFetch() {
        guard !pomodoroManager.isActive, !settingsStore.reactionsPaused else { return }
        fetchBone()
    }

    /// Run off-screen and come back carrying a bone (which lasts 5 minutes).
    func fetchBone() {
        overlayController.performFetch { [weak self] in self?.giveBone() }
    }

    private func giveBone() {
        dogViewModel.hasBone = true
        boneTimer?.invalidate()
        boneTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.dogViewModel.hasBone = false }
        }
    }

    // MARK: - Onboarding

    private func showOnboardingIfNeeded() {
        guard !settingsStore.didOnboard else { return }
        let hosting = NSHostingView(rootView: OnboardingView(
            onEnableTyping: { [weak self] in self?.permissionManager.promptForAccessibility() },
            onDone: { [weak self] in self?.finishOnboarding() }
        ))
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: hosting.fittingSize),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false
        )
        window.title = "Welcome to Waggle"
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        onboardingWindow = window
    }

    private func finishOnboarding() {
        settingsStore.didOnboard = true
        onboardingWindow?.close()
        onboardingWindow = nil
    }

    /// Post system notifications on stretch + Pomodoro transitions (when enabled
    /// and not paused).
    private func observeNotifications() {
        pomodoroManager.onEvent = { [weak self] event in
            switch event {
            case .breakStarted(let isLong):
                self?.notify(isLong ? "Long break — go relax 🛁" : "Break time — go relax 🛁")
            case .focusStarted:
                self?.notify("Back to focus 🐶")
            case .finished:
                self?.notify("Pomodoro set complete! 🎉")
            }
        }
        stretchNotifyCancellable = stretchManager.$isStretchDue
            .removeDuplicates()
            .sink { [weak self] due in
                if due { self?.notify("Time to stretch! 🐕") }
            }
    }

    private func notify(_ body: String) {
        guard settingsStore.notificationsEnabled, !settingsStore.reactionsPaused else { return }
        notificationManager.notify(body)
    }

    /// Configure the cursor/typing reactions from settings (off while paused).
    private func applyInputReactions() {
        let paused = settingsStore.reactionsPaused
        inputMonitor.setReactions(
            cursor: settingsStore.reactCursor,
            typing: settingsStore.reactTyping,
            paused: paused
        )
    }

    /// Stroll across the screen during Pomodoro breaks — but pause (and stay put)
    /// while a stretch nudge is active so the dog can be clicked to dismiss it.
    private func observeRoaming() {
        let onBreak = pomodoroManager.$state.map { state -> Bool in
            if case .breakTime = state { return true }
            return false
        }
        breakCancellable = Publishers.CombineLatest(onBreak, stretchManager.$isStretchDue)
            .map { breaking, stretchDue in breaking && !stretchDue }
            .removeDuplicates()
            .sink { [weak self] shouldRoam in
                if shouldRoam {
                    self?.overlayController.startRoaming()
                } else {
                    self?.overlayController.stopRoaming()
                }
            }
    }

    private func installMenuBar() {
        menuBarController = MenuBarController(
            onAction: { [weak self] action in self?.perform(action) },
            state: { [weak self] in self?.menuState() ?? AppEnvironment.defaultMenuState }
        )
    }

    private func menuState() -> MenuBarState {
        MenuBarState(
            pomodoroActive: pomodoroManager.isActive,
            overlayVisible: overlayController.isOverlayVisible,
            coatID: dogViewModel.coat.id,
            focusMinutes: settingsStore.pomodoroFocusMinutes,
            breakMinutes: settingsStore.pomodoroBreakMinutes,
            stretchMinutes: settingsStore.stretchIntervalMinutes,
            stretchEnabled: settingsStore.stretchEnabled,
            reactionsPaused: settingsStore.reactionsPaused,
            reactCursor: settingsStore.reactCursor,
            reactTyping: settingsStore.reactTyping,
            launchAtLogin: launchItem.isEnabled,
            launchAvailable: launchItem.isAvailable
        )
    }

    private static let defaultMenuState = MenuBarState(
        pomodoroActive: false, overlayVisible: true, coatID: DogCoat.default.id,
        focusMinutes: 25, breakMinutes: 5, stretchMinutes: 45, stretchEnabled: true,
        reactionsPaused: false, reactCursor: true, reactTyping: true,
        launchAtLogin: false, launchAvailable: true
    )

    /// Route an action (from the menu bar or Settings window) to the owning
    /// manager. No logic lives in the UI — every case delegates here.
    func perform(_ action: MenuBarAction) {
        objectWillChange.send() // let the Settings window reflect the change
        switch action {
        case .startPomodoro: pomodoroManager.start()
        case .stopPomodoro: pomodoroManager.stop()
        case .resetStretchTimer: stretchManager.reset()
        case .showWaggle: overlayController.setVisible(true)
        case .hideWaggle: overlayController.setVisible(false)
        case .openAccessibilitySettings: permissionManager.promptForAccessibility()
        case .setDogCoat(let id): selectDogCoat(id)
        case .setFocusMinutes(let m): settingsStore.pomodoroFocusMinutes = m
        case .setBreakMinutes(let m): settingsStore.pomodoroBreakMinutes = m
        case .setStretchMinutes(let m): setStretchMinutes(m)
        case .setReactCursor(let on): settingsStore.reactCursor = on; applyInputReactions()
        case .setReactTyping(let on): settingsStore.reactTyping = on; applyInputReactions()
        case .setReactionsPaused(let paused): setReactionsPaused(paused)
        case .setNotificationsEnabled(let on): settingsStore.notificationsEnabled = on
        case .setLongBreakMinutes(let m): settingsStore.pomodoroLongBreakMinutes = m
        case .setSessionsBeforeLongBreak(let n): settingsStore.pomodoroSessionsBeforeLongBreak = n
        case .setLaunchAtLogin(let on): launchItem.setEnabled(on)
        case .fetchBone: fetchBone()
        case .openSettings: openSettings()
        case .quit: NSApplication.shared.terminate(nil)
        }
    }

    private func setReactionsPaused(_ paused: Bool) {
        settingsStore.reactionsPaused = paused
        applyInputReactions()
        if paused {
            stretchManager.suspend()
        } else {
            stretchManager.start()
        }
    }

    private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(env: self)
        }
        settingsWindowController?.show()
    }

    /// Apply and persist a dog coat selection.
    private func selectDogCoat(_ id: String) {
        settingsStore.dogCoatID = id
        dogViewModel.coat = DogCoat.coat(id: id)
    }

    /// Set the stretch interval (0 = off) and restart the countdown so it takes
    /// effect immediately.
    private func setStretchMinutes(_ minutes: Int) {
        if minutes == 0 {
            settingsStore.stretchEnabled = false
        } else {
            settingsStore.stretchEnabled = true
            settingsStore.stretchIntervalMinutes = minutes
        }
        stretchManager.reset()
    }
}
