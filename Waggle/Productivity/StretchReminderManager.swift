import Foundation

/// Placeholder for the stretch reminder timer (Task 006). Will fire on the
/// configured interval and put the dog into the stretching state until
/// dismissed. Not implemented in the MVP scaffold.
@MainActor
final class StretchReminderManager: ObservableObject {
    @Published private(set) var timerState: TimerState = .idle
}
