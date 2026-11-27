# Task 005 — Typing Reaction

**Status: Complete**

## Goal

Make the dog react when the user types.

## Files Likely Involved

- `Input/TypingTracker.swift`
- `Input/GlobalInputMonitor.swift`
- `Dog/DogViewModel.swift`

## Requirements

- Detect generic key down activity.
- Do not store key values or typed text.
- Do not inspect characters, key codes, or modifiers.
- Trigger typing state.
- Debounce return from typing state.

## Acceptance Criteria

- Typing triggers dog typing reaction.
- Typing state ends after inactivity.
- No sensitive input data is stored.
- Disabling the reaction removes the global key monitor.
