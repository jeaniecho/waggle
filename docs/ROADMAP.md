# Waggle Roadmap

## Implemented

- Native SwiftUI + AppKit application lifecycle
- Transparent floating dog overlay, dragging, and position persistence
- Cursor proximity/direction, generic typing activity, idle, drowsy, and sleep states
- Accessibility onboarding and live reaction toggles
- Stretch reminders and generic system notifications
- Pomodoro focus, short/long breaks, pause/resume, and session counting
- Menu bar, Settings, coat colours, bone fetch, and launch at login
- App/menu icons, packaging script, and sprite asset fallback pipeline
- State-machine and Pomodoro transition tests

The current dog is a SwiftUI-drawn production fallback. The sprite pipeline can
replace individual states with PNG frames without changing state management.

## Before the first public release

- Choose and add a license
- Record a live demo and add release screenshots
- Complete manual Accessibility and multi-display verification
- Run release signing, notarization, and Gatekeeper checks
- Choose a release format and update strategy
- Review repository metadata, topics, contribution guidance, and issue templates
- Move the public default branch to `main` only after the release branch is ready

## Later

- English/Korean localization
- Final sprite art and broader visual polish
- Optional signed auto-updates and a drag-to-Applications DMG

Distribution and localization remain intentionally deferred in Tasks 018–019.
