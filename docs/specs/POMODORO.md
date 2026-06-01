# Pomodoro Specification

## Goal

Support focus and break cycles with dog state changes.

## Defaults

- Focus: 25 minutes
- Break: 5 minutes

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
- Return to idle or offer next focus cycle.

Stop:
- Return Pomodoro to idle.
- Dog returns to highest-priority non-Pomodoro state.

## Menu Bar Controls

- Start Pomodoro
- Stop Pomodoro
- Reset Pomodoro

## Acceptance Criteria

- User can start Pomodoro.
- User can stop Pomodoro.
- State updates over time.
- Dog behavior changes for focus and break.
- Durations persist in settings.
