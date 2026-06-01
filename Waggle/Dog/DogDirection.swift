import CoreGraphics
import Foundation

/// Facing direction of the dog relative to the cursor.
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

extension DogDirection {
    /// Direction from the dog toward the cursor for a screen-space delta, where
    /// `dx` is right-positive and `dy` is up-positive (matching macOS screen
    /// coordinates). The angle is bucketed into the eight compass directions in
    /// 45° sectors; `.center` is returned only when there is no offset.
    ///
    /// Pure and side-effect free so it can be unit tested directly.
    static func from(dx: CGFloat, dy: CGFloat) -> DogDirection {
        if dx == 0 && dy == 0 { return .center }

        // atan2 measures from the +x axis (right), counter-clockwise.
        let degrees = atan2(dy, dx) * 180 / .pi
        let normalized = (degrees + 360).truncatingRemainder(dividingBy: 360) // 0..<360

        switch normalized {
        case 22.5 ..< 67.5:   return .upperRight
        case 67.5 ..< 112.5:  return .up
        case 112.5 ..< 157.5: return .upperLeft
        case 157.5 ..< 202.5: return .left
        case 202.5 ..< 247.5: return .lowerLeft
        case 247.5 ..< 292.5: return .down
        case 292.5 ..< 337.5: return .lowerRight
        default:              return .right // [337.5, 360) and [0, 22.5)
        }
    }
}
