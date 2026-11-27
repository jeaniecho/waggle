# Waggle Product Specification

## Vision

Waggle is a tiny desktop dog that makes focused work feel warmer and healthier.

It should feel alive, subtle, and useful without interrupting the user.

## Product Promise

A small companion on your Mac that:
- Reacts when you work.
- Nudges you to stretch.
- Keeps you company during focus sessions.
- Makes your desktop feel less sterile.

## Target Users

Primary:
- Software engineers
- Designers
- Remote workers
- Students

Secondary:
- People who enjoy desktop pets
- People who use Pomodoro apps but want something softer

## MVP User Experience

A user should be able to:
1. Launch Waggle.
2. See a tiny dog on the desktop.
3. Drag the dog somewhere comfortable.
4. Move the cursor near it and see it react.
5. Type and see it react.
6. Receive a stretch reminder.
7. Start a Pomodoro session.
8. Quit from the menu bar.

## Visual Personality

Waggle should feel:
- Cute
- Calm
- Playful
- Lightweight
- Not childish to the point of being unusable at work

## Visual Style

Preferred:
- Pixel-art dog
- Transparent PNG frames
- Limited animation frames
- Small scale, like a desktop companion

Current implementation:
- A SwiftUI-drawn dog is the production fallback.
- Optional PNG sprite frames can replace individual animation states.

## Core Features

### Desktop Dog Overlay
A small dog that floats above normal windows.

### Dragging
The user can place the dog anywhere.

### Cursor Reaction
The dog looks toward the cursor and becomes excited when the cursor comes close.

### Typing Reaction
The dog reacts when the user types, without storing what was typed.

### Stretch Reminder
The dog periodically nudges the user to stretch.

### Pomodoro Mode
The dog behaves differently during focus and break sessions.

## MVP Non-Goals

- Cloud sync
- Accounts
- Team features
- Analytics
- Marketplace
- App Store distribution
- Cross-platform support
- Final sprite art
- Monetization

## Success Criteria

The MVP succeeds if:
- The overlay feels stable.
- The dog feels alive.
- The app does not interfere with work.
- The stretch and Pomodoro features are understandable.
- The user wants to keep it running for a full work session.
