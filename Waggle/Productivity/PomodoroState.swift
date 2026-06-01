import Foundation

/// Phase of a Pomodoro session. Drives focusing/breakTime dog states (Task 007).
enum PomodoroState: Equatable {
    case inactive
    case focus
    case onBreak
}
