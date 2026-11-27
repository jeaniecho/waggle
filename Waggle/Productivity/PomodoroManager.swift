import Foundation

/// A notable Pomodoro transition, for notifications etc.
enum PomodoroEvent: Equatable {
    case breakStarted(isLong: Bool)
    case focusStarted
    case finished // a full set completed (after the long break)
}

/// Runs Pomodoro focus/break cycles, counting down each interval and driving
/// the dog's focusing/breakTime states.
///
/// Flow: focus → break → focus → … and every Nth break is a long break, after
/// which the set finishes (idle). The user can pause/resume or stop at any time.
/// Durations + N come from `SettingsStore` and persist (defaults: 25/5/15 min,
/// 4 sessions — see docs/specs/POMODORO.md).
@MainActor
final class PomodoroManager: ObservableObject {
    @Published private(set) var state: PomodoroState = .idle
    /// Focus sessions completed in the current set (resets after a long break).
    @Published private(set) var completedSessions: Int = 0

    /// Called on notable transitions (break/focus/finished).
    var onEvent: ((PomodoroEvent) -> Void)?

    private let settingsStore: SettingsStore
    private let dogViewModel: DogViewModel
    private var ticker: Timer?
    private var remaining = 0
    /// The phase to return to from `.paused`.
    private var pausedState: PomodoroState?
    /// Whether the current break is a long break.
    private var isLongBreak = false

    init(settingsStore: SettingsStore, dogViewModel: DogViewModel) {
        self.settingsStore = settingsStore
        self.dogViewModel = dogViewModel
    }

    var isActive: Bool {
        if case .idle = state { return false }
        return true
    }

    var isPaused: Bool {
        if case .paused = state { return true }
        return false
    }

    private var focusSeconds: Int { max(1, settingsStore.pomodoroFocusMinutes) * 60 }
    private var breakSeconds: Int { max(1, settingsStore.pomodoroBreakMinutes) * 60 }
    private var longBreakSeconds: Int { max(1, settingsStore.pomodoroLongBreakMinutes) * 60 }
    private var sessionsBeforeLongBreak: Int { max(1, settingsStore.pomodoroSessionsBeforeLongBreak) }

    // MARK: - Controls

    /// Start (or restart) a fresh set from the first focus session.
    func start() {
        pausedState = nil
        completedSessions = 0
        isLongBreak = false
        beginPhase(.focusing(remainingSeconds: focusSeconds))
    }

    /// Stop the session and return the dog to its non-Pomodoro state.
    func stop() {
        stopTicker()
        pausedState = nil
        setState(.idle)
    }

    /// Reset is a fresh start.
    func reset() {
        start()
    }

    func pause() {
        switch state {
        case .focusing, .breakTime:
            stopTicker()
            pausedState = state
            setState(.paused)
        default:
            break
        }
    }

    func resume() {
        guard case .paused = state, let resumeState = pausedState else { return }
        pausedState = nil
        beginPhase(resumeState)
    }

    // MARK: - Internals

    private func beginPhase(_ newState: PomodoroState) {
        switch newState {
        case .focusing(let seconds): remaining = seconds
        case .breakTime(let seconds): remaining = seconds
        case .idle, .paused: remaining = 0
        }
        setState(newState)
        startTicker()
    }

    /// Advance the state machine by one second. Kept internal so unit tests can
    /// verify transitions without waiting for wall-clock minutes.
    func advanceOneSecond() {
        remaining -= 1

        if remaining <= 0 {
            switch state {
            case .focusing:
                completedSessions += 1
                isLongBreak = completedSessions % sessionsBeforeLongBreak == 0
                onEvent?(.breakStarted(isLong: isLongBreak))
                beginPhase(.breakTime(remainingSeconds: isLongBreak ? longBreakSeconds : breakSeconds))
            case .breakTime:
                if isLongBreak {
                    isLongBreak = false
                    completedSessions = 0
                    onEvent?(.finished)
                    stop() // set complete → idle
                } else {
                    onEvent?(.focusStarted)
                    beginPhase(.focusing(remainingSeconds: focusSeconds))
                }
            default:
                stopTicker()
            }
            return
        }

        switch state {
        case .focusing: setState(.focusing(remainingSeconds: remaining))
        case .breakTime: setState(.breakTime(remainingSeconds: remaining))
        default: break
        }
    }

    private func startTicker() {
        stopTicker()
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.advanceOneSecond() }
        }
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    /// Update the published state and mirror the phase onto the dog.
    private func setState(_ newState: PomodoroState) {
        state = newState
        switch newState {
        case .focusing:
            dogViewModel.setBreakTime(false)
            dogViewModel.setFocusing(true)
        case .breakTime:
            dogViewModel.setFocusing(false)
            dogViewModel.setBreakTime(true)
        case .idle, .paused:
            dogViewModel.setFocusing(false)
            dogViewModel.setBreakTime(false)
        }
    }

    deinit {
        ticker?.invalidate()
    }
}
