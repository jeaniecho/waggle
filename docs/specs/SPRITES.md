# Sprite and Animation Specification

## MVP

Use placeholder SwiftUI shapes first.

## Final Direction

Use pixel-art transparent PNG sprites.

## Suggested Sprite States

- idle
- blink
- tail wag
- typing
- dragged
- stretch
- sleep/focus
- celebrate/break

## Asset Rules

- Transparent PNG
- Consistent canvas size
- Pixel-perfect scaling
- Avoid blur by using nearest-neighbor style rendering where practical
- Keep frame count small for MVP

## Placeholder Requirement

Do not block implementation waiting for final sprites.

DogSpriteView should make replacing placeholder visuals easy.
