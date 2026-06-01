# Overlay Specification

## Goal

Create a transparent always-on-top desktop overlay that hosts the dog.

## Requirements

- Borderless AppKit window
- Transparent background
- Floating window level
- SwiftUI content hosted inside
- Window size fits dog content
- Dog can be shown/hidden
- App can quit cleanly

## AppKit Guidance

Use an `NSWindow` or `NSPanel` subclass/wrapper.

Expected properties:
- `styleMask` includes borderless behavior
- `isOpaque = false`
- `backgroundColor = .clear`
- floating window level
- no titlebar
- content view hosts SwiftUI

## Acceptance Criteria

- App launches.
- Overlay appears.
- Background is transparent.
- Dog view is visible.
- Overlay stays above normal app windows.
- Overlay does not show a normal document window.
