import Foundation

/// Placeholder for the Pomodoro state machine (Task 007). Will publish
/// focus/break transitions to the dog view model. Not implemented in the MVP
/// scaffold.
@MainActor
final class PomodoroManager: ObservableObject {
    @Published private(set) var state: PomodoroState = .inactive
    @Published private(set) var timerState: TimerState = .idle
}
