# Task 011 — Per-Reaction Toggles

**Status: Complete**

## Goal
Let the user enable/disable individual reactions.

## Toggles
- Cursor reaction (watch/excited)
- Generic typing reaction (alternating ear flaps and typing state)

## Requirements
- Persisted settings (default on).
- When off, the relevant tracker stops; the global typing monitor is removed.
- Typing toggle independent of the Accessibility permission gate.

## Acceptance Criteria
- Turning a reaction off stops that behaviour live; on re-enables it.
