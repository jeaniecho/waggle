# Pomodoro Specification

## Goal

Support focus and break cycles with dog state changes.

## Defaults

- Focus: 25 minutes
- Short break: 5 minutes
- Long break: 15 minutes after 4 completed focus sessions

## States

```swift
enum PomodoroState: Equatable {
    case idle
    case focusing(remainingSeconds: Int)
    case breakTime(remainingSeconds: Int)
    case paused
}
```

## Behavior

Start:
- Enter focus state.
- Dog enters focusing/sleep/guard behavior.

Focus complete:
- Enter break state.
- Dog celebrates/wags.

Break complete:
- Start the next focus cycle after a short break.
- Return to idle after the long break completes the set.

Stop:
- Return Pomodoro to idle.
- Dog returns to highest-priority non-Pomodoro state.

## Menu Bar Controls

- Start Pomodoro
- Stop Pomodoro
- Reset Pomodoro

The right-click overlay menu also supports pause/resume. Durations and the
long-break session count are configurable in Settings.

## Acceptance Criteria

- User can start Pomodoro.
- User can stop Pomodoro.
- State updates over time.
- Dog behavior changes for focus and break.
- Durations persist in settings.
