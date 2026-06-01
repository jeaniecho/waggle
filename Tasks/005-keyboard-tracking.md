# Task 005 — Typing Reaction

## Goal

Make the dog react when the user types.

## Files Likely Involved

- `Input/TypingTracker.swift`
- `Input/GlobalInputMonitor.swift`
- `Dog/DogViewModel.swift`

## Requirements

- Detect generic key down activity.
- Do not store key values or typed text.
- Trigger typing state.
- Debounce return from typing state.

## Acceptance Criteria

- Typing triggers dog typing reaction.
- Typing state ends after inactivity.
- No sensitive input data is stored.
