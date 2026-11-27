# Task 012 — Launch at Login

**Status: Complete**

## Goal
Option to start Waggle automatically at login.

## Requirements
- Use `SMAppService.mainApp` (macOS 13+); hide/disable the option on macOS 12.
- Toggle in Settings (and/or menu bar); reflect the real registration state.

## Acceptance Criteria
- Enabling registers the login item; disabling removes it; survives relaunch.
