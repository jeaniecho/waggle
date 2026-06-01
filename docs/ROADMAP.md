# Waggle Roadmap

## Phase 0 — Starter Kit

Goal:
Create documentation and Claude Code workflow for reliable implementation.

Deliverables:
- CLAUDE.md
- Product spec
- Architecture spec
- Task prompts
- ADRs
- Engineering conventions

Status:
Complete

## Phase 1 — Foundation

Goal:
Create a runnable macOS overlay app.

Deliverables:
- Xcode project
- App lifecycle
- Transparent overlay window
- SwiftUI hosted placeholder dog
- Dragging
- Position persistence

Definition of done:
- App builds.
- Dog appears.
- Dog can be dragged.
- Position restores after relaunch.

## Phase 2 — Input Reactions

Goal:
Make the dog feel alive.

Deliverables:
- Accessibility permission manager
- Cursor tracker
- Direction calculation
- Nearby cursor reaction
- Typing tracker
- Typing state debounce

Definition of done:
- Cursor movement affects dog state.
- Typing triggers temporary reaction.
- App behaves clearly if permission is missing.

## Phase 3 — Productivity

Goal:
Add functional value.

Deliverables:
- Stretch reminder manager
- Pomodoro manager
- Menu bar controls
- Basic settings persistence

Definition of done:
- Stretch reminder fires.
- User can reset reminder.
- User can start/stop Pomodoro.
- Dog behavior changes during focus/break.

## Phase 4 — Visual Polish

Goal:
Replace placeholders with a lovable pet.

Deliverables:
- Pixel-art sprites
- Idle animation
- Tail wag animation
- Typing animation
- Stretch animation
- Sleep/focus animation
- Celebrate animation

Definition of done:
- Dog looks coherent in all MVP states.

## Phase 5 — Local Distribution

Goal:
Make the app comfortable for personal use.

Deliverables:
- App icon
- Better permission UX
- Release build notes
- Optional launch-at-login
- Optional notarization

Definition of done:
- User can install/run without developer friction.
