# Task 010 — Settings Window

**Status: Complete**

## Goal
A proper SwiftUI Settings window (Cmd-,) so config isn't only in the menu bar.

## Tabs
- General: launch at login, reaction toggles (cursor, typing), pause reactions.
- Productivity: stretch on/off + interval, Pomodoro focus/break/long-break +
  sessions-before-long-break.
- Appearance: dog colour.
- About: app name, version, links, "100% local — no tracking".

## Requirements
- Bind to a single observable settings source; persist to UserDefaults.
- Changing a value applies immediately (e.g. stretch interval restarts timer).
- Keep the menu bar controls working (same source of truth).

## Acceptance Criteria
- Cmd-, opens the window; changes persist and take effect live.
