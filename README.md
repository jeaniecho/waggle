# Waggle

A tiny macOS desktop dog that helps you pause, focus, and stretch.

Waggle is a local-first desktop pet built with SwiftUI + AppKit. It lives in a transparent always-on-top overlay, reacts to your cursor and typing, and gently supports healthier work sessions through stretch reminders and Pomodoro mode.

## MVP Features

- Transparent always-on-top dog overlay
- Draggable desktop dog
- Cursor reaction
- Typing reaction
- Stretch reminders
- Pomodoro focus/break mode
- Accessibility permission flow
- Local settings persistence

## Platform

- macOS 12+
- Swift
- SwiftUI
- AppKit

## Project Status

Production-grade starter kit created. App implementation has not started yet.

Recommended first implementation milestone:

```text
Create a runnable transparent always-on-top draggable placeholder dog overlay.
```

## Development Principles

- Native macOS first
- Local-first
- No backend
- No analytics
- No external dependencies for MVP
- Placeholder visuals first, pixel-art sprites later

## Documentation

- `CLAUDE.md` — Claude Code operating instructions
- `docs/ARCHITECTURE.md` — system architecture
- `docs/PRODUCT.md` — product definition
- `docs/ROADMAP.md` — phased roadmap
- `docs/DECISIONS.md` — architectural decisions
- `docs/specs/` — detailed feature specs
- `Tasks/` — implementation task prompts

## Permissions

Global cursor and typing reactions may require macOS Accessibility permission.

Path:

```text
System Settings > Privacy & Security > Accessibility
```

Enable Waggle after first launch when prompted.

## Privacy

Waggle should never store typed content, key names, app names, window titles, or cursor history. Keyboard detection exists only to trigger a generic typing animation.

## License

TBD.
