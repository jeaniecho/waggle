import Foundation

/// Maps a visual `DogAnimationState` to its ordered sprite frame asset names.
///
/// Frames are looked up by name (asset catalog image set or bundled PNG). When
/// the named frames are missing, `DogSpriteView` falls back to the placeholder
/// shapes, so the app stays functional with no art.
///
/// Naming convention: `dog_<state>_<frameIndex>` starting at 0
/// (see docs/specs/SPRITES.md). Drop PNGs with these names into Assets.xcassets
/// to replace the placeholder — no code changes required.
enum DogSprite {
    /// Playback rate for states with more than one frame.
    static let framesPerSecond: Double = 4

    static func frameNames(for state: DogAnimationState) -> [String] {
        switch state {
        case .idle:      return ["dog_idle_0", "dog_idle_1"]
        case .drowsy:    return []
        case .sleeping:  return []
        case .blink:     return ["dog_idle_0", "dog_blink_0"]
        case .tailWag:   return ["dog_tail_wag_0", "dog_tail_wag_1"]
        case .typing:    return ["dog_typing_0", "dog_typing_1"]
        case .dragged:   return ["dog_dragged_0"]
        case .stretch:   return ["dog_stretch_0"]
        case .sleep:     return ["dog_sleep_0"]
        case .celebrate: return ["dog_celebrate_0"]
        }
    }
}
