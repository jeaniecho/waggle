# Dog State Machine

## Semantic State

```swift
enum DogState: Equatable {
    case idle
    case watchingCursor(direction: DogDirection)
    case excited
    case typing
    case dragging
    case stretching
    case focusing
    case breakTime
}
```

## Animation State

```swift
enum DogAnimationState: Equatable {
    case idle
    case tailWag
    case blink
    case typing
    case dragged
    case stretch
    case sleep
    case celebrate
}
```

## Direction

```swift
enum DogDirection: Equatable {
    case left
    case right
    case up
    case down
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight
    case center
}
```

## Priority

1. Dragging
2. Stretching
3. Break time
4. Focusing
5. Typing
6. Watching cursor
7. Idle

## Mapping

| Dog State | Animation |
|---|---|
| idle | idle/blink |
| watchingCursor | tailWag |
| excited | tailWag |
| typing | typing |
| dragging | dragged |
| stretching | stretch |
| focusing | sleep |
| breakTime | celebrate |
