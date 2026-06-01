# Coding Standards

## Swift Style

- Prefer clear names over abbreviations.
- Prefer small focused types.
- Prefer `final class` unless subclassing is required.
- Prefer `struct` for value types.
- Use `@MainActor` for UI-facing observable objects.
- Avoid force unwraps.
- Avoid global mutable state.

## File Organization

- One main type per file.
- Keep files under roughly 250 lines where practical.
- Use folders that match architecture layers.

## State

- Keep semantic state separate from animation state.
- Avoid view-local business logic.
- Let view models coordinate state priority.

## AppKit

- Isolate AppKit window behavior in the Overlay layer.
- SwiftUI views should not directly configure window flags.
- Comment non-obvious AppKit settings.

## Timers

- Ensure timers can be invalidated.
- Avoid retain cycles.
- Keep default durations in settings or constants.

## Privacy

Never store:
- Typed content
- Key names
- Cursor history
- App names
- Window titles

## Dependencies

Do not add external dependencies for MVP.
