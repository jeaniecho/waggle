# Task 003 — Cursor Tracking

**Status: Complete**

## Goal

Make the dog react to cursor movement.

## Files Likely Involved

- `Input/CursorTracker.swift`
- `Input/GlobalInputMonitor.swift`
- `Dog/DogViewModel.swift`
- `Dog/DogDirection.swift`

## Requirements

- Track global cursor position.
- Calculate direction from dog to cursor.
- Detect cursor proximity.
- Dog enters watching/excited state when nearby.
- Dog returns to idle when far away.

## Acceptance Criteria

- Moving cursor near dog changes dog state.
- Moving cursor away returns dog to idle.
- Direction calculation is understandable and testable.
