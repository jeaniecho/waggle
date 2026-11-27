# Waggle Architecture

## Overview

Waggle is a native macOS desktop overlay app. It combines AppKit for windowing and system-level behavior with SwiftUI for rendering the pet UI.

The architecture is intentionally simple:

```text
App lifecycle
  -> App environment
  -> Overlay window
  -> SwiftUI dog view
  -> Dog state model
  -> Input/productivity managers
```

## Layers

## 1. App Layer

Responsibilities:
- Launch the app.
- Configure app delegate behavior.
- Create shared managers.
- Create the overlay window.
- Wire menu bar actions.

Files:
- `WaggleApp.swift`
- `AppDelegate.swift`
- `AppEnvironment.swift`

## 2. Overlay Layer

Responsibilities:
- Create transparent always-on-top AppKit window.
- Host SwiftUI dog view.
- Handle window-level drag behavior.
- Persist and restore position.

Files:
- `DogOverlayWindow.swift`
- `DogOverlayWindowController.swift`
- `DogOverlayView.swift`
- `OverlayPositionStore.swift`

## 3. Dog Layer

Responsibilities:
- Maintain semantic dog state.
- Translate state into animation state.
- Render placeholder/sprite dog.
- Track direction to cursor.

Files:
- `DogViewModel.swift`
- `DogState.swift`
- `DogAnimationState.swift`
- `DogSpriteView.swift`
- `DogDirection.swift`

## 4. Input Layer

Responsibilities:
- Monitor global cursor movement.
- Monitor global keyboard events.
- Check and request Accessibility permission.
- Publish generic input events.

Files:
- `GlobalInputMonitor.swift`
- `AccessibilityPermissionManager.swift`
- `CursorTracker.swift`
- `TypingTracker.swift`
- `InputEvent.swift`

## 5. Productivity Layer

Responsibilities:
- Stretch reminder timer.
- Pomodoro state machine.
- Publish timer-driven events to dog view model.

Files:
- `StretchReminderManager.swift`
- `PomodoroManager.swift`
- `PomodoroState.swift`
- `TimerState.swift`

## 6. Menu Bar Layer

Responsibilities:
- Provide app-level controls.
- Let user start/stop Pomodoro.
- Reset stretch timer.
- Show/hide overlay.
- Quit app.

Files:
- `MenuBarController.swift`
- `MenuBarAction.swift`

## 7. Settings Layer

Responsibilities:
- Define app settings.
- Read/write UserDefaults.
- Persist dog position and timer options.

Files:
- `AppSettings.swift`
- `SettingsStore.swift`
- `UserDefaultsKeys.swift`

## Event Flow

### Cursor

```text
NSEvent global mouse monitor
  -> CursorTracker
  -> GlobalInputMonitor
  -> DogViewModel
  -> DogOverlayView
  -> DogSpriteView
```

### Typing

```text
NSEvent global key monitor
  -> TypingTracker
  -> DogViewModel
  -> temporary typing state
  -> previous state or idle
```

### Stretch Reminder

```text
StretchReminderManager
  -> stretch due event
  -> DogViewModel
  -> stretching state
  -> user dismisses
  -> timer resets
```

### Pomodoro

```text
PomodoroManager
  -> focus/break state
  -> DogViewModel
  -> focusing/breakTime state
```

## State Priority

When multiple states compete:

1. Dragging
2. Stretch reminder due
3. Pomodoro break
4. Pomodoro focus
5. Typing
6. Cursor nearby
7. Sleeping / drowsy
8. Idle

## Window Design

Use AppKit for the overlay window because SwiftUI alone does not expose enough control over transparent floating windows.

Required characteristics:
- Borderless
- Transparent
- Floating
- Non-activating where possible
- Content-sized
- Movable through custom drag behavior
- Hosted SwiftUI root view

## Persistence Design

Use UserDefaults for MVP.

Persist:
- Dog x/y position
- Appearance and reaction preferences
- Stretch reminder settings
- Pomodoro focus, short-break, long-break, and session-count settings
- Onboarding completion

Do not persist:
- Keystrokes
- Text content
- Cursor movement
- App/window names
- Behavior history

## Possible Extensions

Possible later additions:
- Auto-update
- Multiple pets
- Sound effects
- Local-only customization
