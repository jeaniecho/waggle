# Task 016 — System Notifications

## Goal
Notify on stretch + Pomodoro transitions so the user notices off-screen.

## Requirements
- `UNUserNotificationCenter`; request authorization once (gracefully if denied).
- Notify: stretch due, focus → break, break → focus/idle.
- A setting to turn notifications off (default on); respects Pause Reactions.
- No content beyond generic reminders (privacy).

## Acceptance Criteria
- Notifications appear on the relevant transitions when enabled/authorized.
