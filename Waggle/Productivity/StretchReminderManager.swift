import Foundation

/// Fires a stretch nudge on a configurable interval. When it fires the dog
/// enters the stretching state and stays there until the user resets/dismisses
/// the reminder, at which point the countdown restarts.
///
/// Interval and enabled state come from `SettingsStore` and persist across
/// launches. Defaults: enabled, 45 minutes (see docs/specs/STRETCH_REMINDER.md).
@MainActor
final class StretchReminderManager: ObservableObject {
    @Published private(set) var timerState: TimerState = .idle
    /// True once a nudge has fired and is awaiting dismissal.
    @Published private(set) var isStretchDue = false

    private let settingsStore: SettingsStore
    private let dogViewModel: DogViewModel
    private var timer: Timer?

    init(settingsStore: SettingsStore, dogViewModel: DogViewModel) {
        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
    }

    /// Start the countdown if stretch reminders are enabled.
    func start() {
        guard settingsStore.stretchEnabled else {
            stop()
            return
        }
        scheduleTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        timerState = .idle
    }

    /// Dismiss the current nudge (if any) and restart the countdown.
    func reset() {
        isStretchDue = false
        dogViewModel.setStretching(false)
        start()
    }

    // MARK: - Internals

    /// Interval elapsed: nudge the dog to stretch and wait for a reset.
    private func fire() {
        timer = nil
        timerState = .idle
        isStretchDue = true
        dogViewModel.setStretching(true)
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let seconds = TimeInterval(max(1, settingsStore.stretchIntervalMinutes) * 60)
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.fire() }
        }
        timerState = .running
    }

    deinit {
        timer?.invalidate()
    }
}
