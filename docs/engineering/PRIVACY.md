# Privacy Design

Waggle is local-first and has no networking, account, analytics, advertising,
or telemetry layer.

## Stored locally

Waggle uses `UserDefaults` for:

- dog position and coat choice
- onboarding completion
- launch, notification, and reaction preferences
- stretch interval and enabled state
- Pomodoro focus, short-break, long-break, and session-count settings

The app does not persist activity history.

## Typing activity

The optional typing reaction installs an AppKit global `.keyDown` monitor only
after Accessibility access is granted. Its event parameter is intentionally
ignored. The implementation does not inspect characters, key codes, modifiers,
the foreground application, or window information. It emits only:

- an unspecified key-down occurred, used for an ear flap
- typing is active/inactive, using an 800 ms inactivity debounce

Turning off typing reactions, pausing all reactions, or quitting the app removes
the global keyboard monitor and clears the active typing state.

## Cursor activity

The current global cursor location is used in memory to calculate direction and
distance from the dog. No cursor path or history is stored. Cursor reactions do
not require Accessibility permission and can be disabled independently; doing
so removes both the global and local cursor monitors.

## Never collected or stored

- typed text, key names, shortcuts, or keyboard history
- application names or window titles
- cursor history
- screenshots, clipboard contents, documents, or file names
- behavior analytics or device identifiers

## Permissions

Accessibility is optional and used only for the typing activity signal. The
overlay, dragging, cursor reaction, timers, settings, and menu bar remain usable
without it. Notification permission is separately requested for generic stretch
and Pomodoro reminders.
