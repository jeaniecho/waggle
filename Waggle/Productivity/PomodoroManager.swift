import Foundation

/// Runs Pomodoro focus/break cycles, counting down each interval and driving
/// the dog's focusing/breakTime states.
///
/// Flow: start → focus → (auto) break → (auto) idle. The user can pause/resume
/// or stop/reset at any time. Durations come from `SettingsStore` and persist
/// (defaults: 25 min focus, 5 min break — see docs/specs/POMODORO.md).
@MainActor
final class PomodoroManager: ObservableObject {
    @Published private(set) var state: PomodoroState = .idle

    private let settingsStore: SettingsStore
    private let dogViewModel: DogViewModel
    private var ticker: Timer?
    private var remaining = 0
    /// The phase to return to from `.paused`.
    private var pausedState: PomodoroState?

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

    /// Fraction (0…1) of the current focus/break interval still remaining, for a
    /// progress ring. 0 when idle.
    var remainingFraction: Double {
        switch state {
        case .idle:
            return 0
        case .focusing(let r):
            return fraction(r, of: focusSeconds)
        case .breakTime(let r):
            return fraction(r, of: breakSeconds)
        case .paused:
            switch pausedState {
            case .focusing(let r): return fraction(r, of: focusSeconds)
            case .breakTime(let r): return fraction(r, of: breakSeconds)
            default: return 0
            }
        }
    }

    private func fraction(_ remaining: Int, of total: Int) -> Double {
        guard total > 0 else { return 0 }
        return min(1, max(0, Double(remaining) / Double(total)))
    }

    private var focusSeconds: Int { max(1, settingsStore.pomodoroFocusMinutes) * 60 }
    private var breakSeconds: Int { max(1, settingsStore.pomodoroBreakMinutes) * 60 }

    // MARK: - Controls

    /// Start (or restart) a fresh focus session.
    func start() {
        pausedState = nil
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

    private func tick() {
        remaining -= 1

        if remaining <= 0 {
            switch state {
            case .focusing: beginPhase(.breakTime(remainingSeconds: breakSeconds))
            case .breakTime: stop() // break complete → idle
            default: stopTicker()
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
            Task { @MainActor in self?.tick() }
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
