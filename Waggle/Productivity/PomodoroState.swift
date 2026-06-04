import Foundation

/// Phase of a Pomodoro session, carrying the live countdown. Drives the dog's
/// focusing/breakTime states (see docs/specs/POMODORO.md).
enum PomodoroState: Equatable {
    case idle
    case focusing(remainingSeconds: Int)
    case breakTime(remainingSeconds: Int)
    case paused
}
