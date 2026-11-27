# CLAUDE.md

## Project: Waggle

Waggle is a local-first macOS desktop pet app built with SwiftUI + AppKit.

The MVP is a tiny pixel-art dog that appears in a transparent always-on-top desktop overlay. It can be dragged, reacts to cursor movement and typing, reminds the user to stretch, and supports Pomodoro focus/break sessions.

## Current Status

The native MVP is implemented. The checked-in SwiftUI dog is the production
fallback, and the optional PNG sprite pipeline can replace individual states.
Tasks 000–017 are implementation records/specifications rather than an unstarted
backlog; Tasks 018–019 remain deferred. Preserve existing behavior and add tests
when changing state resolution or timers.

## Product Direction

### MVP Platform
- macOS only
- macOS 12+
- Personal/local app first
- No App Store release requirements for MVP

### Tech Stack
- Swift
- SwiftUI
- AppKit
- UserDefaults
- Native macOS APIs only
- No backend
- No analytics
- No telemetry
- No external dependencies unless explicitly justified

### Visual Direction
Use pixel-art dog visuals.

The current SwiftUI-drawn dog must remain functional when sprite frames are
missing. Pixel-art assets may be added as transparent PNG sprite frames.

## Development Philosophy

Claude Code should behave like a careful senior macOS engineer.

Optimize for:
- Stable architecture
- Small focused files
- Native macOS behavior
- Easy replacement of placeholder visuals
- Clear state transitions
- Local-first simplicity
- Runnable increments

Avoid:
- Premature abstraction
- Cross-platform concerns
- Networking
- Analytics
- Hidden background services
- Hardcoded magic values without explanation
- Large files that mix unrelated responsibilities

## Claude Code Workflow

For every non-trivial task, follow:

1. PLAN
   - Restate the goal.
   - Identify files to create/change.
   - Identify risks.
   - Keep the plan short and actionable.

2. IMPLEMENT
   - Make the smallest coherent change.
   - Keep files focused.
   - Prefer explicit code over clever code.

3. VERIFY
   - Run available build/check commands.
   - If a command cannot run locally, state the exact reason.
   - Inspect important files after writing them.

4. DOCUMENT
   - Update task status or docs when behavior changes.
   - Add concise comments only where they clarify non-obvious AppKit behavior.

## Architecture Baseline

The app already builds around an AppKit overlay, SwiftUI rendering, explicit dog
state resolution, input managers, productivity managers, and UserDefaults
persistence. Keep those ownership boundaries intact and make incremental changes.

## Recommended Source Structure

```text
Waggle/
  App/
    WaggleApp.swift
    AppDelegate.swift
    AppEnvironment.swift

  Overlay/
    DogOverlayWindow.swift
    DogOverlayWindowController.swift
    DogOverlayView.swift
    OverlayPositionStore.swift

  Dog/
    DogViewModel.swift
    DogState.swift
    DogAnimationState.swift
    DogSpriteView.swift
    DogDirection.swift

  Input/
    GlobalInputMonitor.swift
    AccessibilityPermissionManager.swift
    CursorTracker.swift
    TypingTracker.swift
    InputEvent.swift

  Productivity/
    StretchReminderManager.swift
    PomodoroManager.swift
    PomodoroState.swift
    TimerState.swift

  MenuBar/
    MenuBarController.swift
    MenuBarAction.swift

  Settings/
    AppSettings.swift
    SettingsStore.swift
    UserDefaultsKeys.swift

  Utilities/
    Logger.swift
    TimeProvider.swift
    Debouncer.swift
```

## MVP Feature List

### 1. Transparent Always-On-Top Dog Overlay
Requirements:
- Borderless transparent AppKit window.
- Floating window level.
- SwiftUI hosted content.
- Window size wraps dog content.
- Does not show a normal app window.
- Should not steal focus during ordinary interaction.

### 2. Draggable Dog
Requirements:
- User can drag the dog by clicking and moving the dog view.
- Dragging updates overlay window position.
- Final position persists with UserDefaults.
- Dog enters `dragging` state during drag and returns to appropriate state after drag.

### 3. Cursor Reaction
Requirements:
- Track global cursor movement.
- Determine direction from dog to cursor.
- Dog reacts when cursor is nearby.
- Dog returns to idle when cursor is far away.
- Keep app usable when permissions are missing.

### 4. Typing Reaction
Requirements:
- Detect global key down events where possible.
- Trigger typing animation briefly after keypress.
- Debounce so continuous typing keeps state active.
- Return to previous state after typing stops.

### 5. Stretch Reminder
Requirements:
- Default interval: 45 minutes.
- Dog enters stretch/nudge state when reminder fires.
- User can dismiss/reset reminder.
- Stretch interval is configurable in settings model.

### 6. Pomodoro Mode
Requirements:
- Default focus duration: 25 minutes.
- Default break duration: 5 minutes.
- Focus state: dog sleeps/guards.
- Break state: dog celebrates/wags.
- Start, pause/stop, reset behavior.
- Menu bar control hooks.

### 7. Accessibility Permission Flow
Requirements:
- Check Accessibility permission.
- Expose permission status to UI.
- Provide a way to open System Settings privacy pane.
- App remains partially usable without permission.

## Dog State Model

Use explicit dog states:

```swift
enum DogState: Equatable {
    case idle
    case drowsy
    case sleeping
    case watchingCursor(direction: DogDirection)
    case excited
    case typing
    case dragging
    case stretching
    case focusing
    case breakTime
}
```

Use separate animation states:

```swift
enum DogAnimationState: Equatable {
    case idle
    case drowsy
    case sleeping
    case tailWag
    case blink
    case typing
    case dragged
    case stretch
    case sleep
    case celebrate
}
```

Dog state is semantic. Animation state is visual. Keep them separate.

## State Priority

When multiple events happen, use this priority:

1. Dragging
2. Stretch reminder due
3. Pomodoro break
4. Pomodoro focus
5. Typing
6. Cursor nearby
7. Sleeping / drowsy
8. Idle

This prevents flickering and makes behavior predictable.

## Coding Standards

### Swift
- Prefer `final class` for reference types that are not subclassed.
- Use `@MainActor` for UI-facing observable objects.
- Use `ObservableObject` and `@Published` for simple MVP state.
- Keep AppKit-specific logic out of SwiftUI views when possible.
- Avoid force unwraps unless truly impossible and documented.
- Use dependency injection for managers where practical, but do not over-engineer.

### Files
- One main type per file.
- Keep files under roughly 250 lines where possible.
- Use clear names.
- Group with `// MARK:` only when helpful.

### Timers
- Ensure timers can be invalidated.
- Avoid retain cycles.
- Keep timer logic testable by using `TimeProvider` where practical.

### Permissions
- Permission checking should be isolated in `AccessibilityPermissionManager`.
- UI should observe permission state, not call permission APIs directly.

## Menu Bar MVP

Add menu bar controls after overlay and core managers exist.

Menu items:
- Start Pomodoro
- Stop Pomodoro
- Reset Stretch Timer
- Show Waggle
- Hide Waggle
- Open Accessibility Settings
- Quit

## Persistence

Use UserDefaults for:
- Dog position
- Stretch enabled
- Stretch interval minutes
- Pomodoro focus minutes
- Pomodoro break minutes
- Last selected simple settings

Do not persist:
- Analytics
- Behavior history
- Keystrokes
- Cursor paths

## Privacy Rules

Waggle must never store:
- Typed text
- Key names
- App names
- Window titles
- Cursor movement history

Keyboard monitoring is only used to trigger a generic "typing" reaction.

## Build Verification

Prefer these checks:
- Open in Xcode and build macOS target.
- Run app manually and verify overlay behavior.
- If command-line build is available, use `xcodebuild`.

When project files are generated, document the exact build command in `docs/engineering/BUILD.md`.

## Done Criteria for MVP

The MVP is complete when:
- App launches locally.
- Dog overlay appears.
- Dog can be dragged.
- Dog reacts to cursor proximity.
- Dog reacts to typing.
- Stretch reminder fires and can be reset.
- Pomodoro focus/break mode changes dog behavior.
- Settings persist across launches.
- User can quit from menu bar.
