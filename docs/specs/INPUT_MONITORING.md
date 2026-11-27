# Input Monitoring Specification

## Goal

Detect generic cursor movement and typing activity without storing sensitive information.

## Cursor Tracking

Cursor tracker should:
- Observe mouse movement globally.
- Publish current cursor position.
- Calculate dog-relative direction.
- Detect proximity to the dog.

Do not store cursor history.

## Typing Tracking

Typing tracker should:
- Detect key down events.
- Publish generic "typing activity" event.
- Never store key value, character, modifier combination, app name, or text content.
- Debounce typing state.
- Install the global monitor only while typing reactions are enabled and
  Accessibility permission is present.

Suggested debounce:
- Keypress triggers typing state.
- If no keypress occurs for 600–1000ms, typing state ends.

## Accessibility Permission

Some global monitoring behavior may require Accessibility permission.

Permission manager should:
- Check current permission.
- Provide a method to request/open settings.
- Publish permission status.
- Let the app remain usable without permission.

## Acceptance Criteria

- Cursor movement can update dog direction.
- Typing triggers generic dog reaction.
- Missing permission is handled gracefully.
- No sensitive input data is persisted.
- Disabling typing reactions removes the global keyboard monitor immediately.
