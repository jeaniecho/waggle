import Foundation

/// Generic run state shared by timer-driven managers (stretch, Pomodoro).
enum TimerState: Equatable {
    case idle
    case running
    case paused
}
