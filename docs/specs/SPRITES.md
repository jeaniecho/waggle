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

## Asset Naming Convention

Frames are named `dog_<state>_<frameIndex>`, with `frameIndex` starting at `0`.
`DogSprite.frameNames(for:)` is the single source of truth; the names it
currently expects are:

| Animation state | Frames |
|---|---|
| idle      | `dog_idle_0`, `dog_idle_1` |
| blink     | `dog_idle_0`, `dog_blink_0` |
| tailWag   | `dog_tail_wag_0`, `dog_tail_wag_1` |
| typing    | `dog_typing_0`, `dog_typing_1` |
| dragged   | `dog_dragged_0` |
| stretch   | `dog_stretch_0` |
| sleep     | `dog_sleep_0` |
| celebrate | `dog_celebrate_0` |

## Adding Sprites Later

1. Create one image set per frame name above in
   `Waggle/Resources/Assets.xcassets` (transparent PNGs, consistent canvas size
   matching `DogSpriteView.size`, ideally @1x/@2x).
2. Rebuild. `DogSpriteView` loads them automatically.

Rules:
- A state's frames are used only if **all** of its named frames are present;
  otherwise that state falls back to the placeholder shapes (mixed art/placeholder
  is avoided).
- Rendering uses nearest-neighbor interpolation (`.interpolation(.none)`) for
  crisp pixels.
- Multi-frame states animate at `DogSprite.framesPerSecond`.

No code changes are needed to adopt assets; to change frame counts or add states,
update `DogSprite.frameNames(for:)`.
