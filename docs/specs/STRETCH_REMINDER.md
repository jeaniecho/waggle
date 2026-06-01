# Stretch Reminder Specification

## Goal

Encourage the user to take periodic stretch breaks.

## Defaults

- Enabled: true
- Interval: 45 minutes

## Behavior

When the timer fires:
1. Dog enters stretching/nudge state.
2. User can dismiss/reset.
3. Timer restarts after dismissal or reset.

## Settings

Persist:
- Stretch enabled
- Stretch interval minutes

## Acceptance Criteria

- Timer starts when app launches if enabled.
- Reminder fires after configured interval.
- Dog state changes to stretching.
- User can reset timer.
- Setting persists across app relaunch.
