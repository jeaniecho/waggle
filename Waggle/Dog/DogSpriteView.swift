import SwiftUI

/// Renders the dog for a given `DogAnimationState`.
///
/// If the state's sprite frames exist (see `DogSprite`), they are drawn with
/// nearest-neighbor scaling (crisp pixel art, no blur) and animated when there
/// is more than one frame. If any frame is missing, the view falls back to the
/// placeholder shapes below — so the app works with or without art, and adding
/// PNGs later needs no code changes.
struct DogSpriteView: View {
    /// Logical canvas size of the dog. The overlay window sizes itself to this.
    static let size = CGSize(width: 96, height: 96)

    var animationState: DogAnimationState = .idle

    var body: some View {
        content
            .frame(width: Self.size.width, height: Self.size.height)
    }

    @ViewBuilder
    private var content: some View {
        let frames = Self.loadFrames(for: animationState)
        if frames.isEmpty {
            PlaceholderDog(isTyping: animationState == .typing)
        } else if frames.count == 1 {
            sprite(frames[0])
        } else {
            TimelineView(.periodic(from: .now, by: 1.0 / DogSprite.framesPerSecond)) { context in
                sprite(frames[Self.frameIndex(at: context.date, count: frames.count)])
            }
        }
    }

    private func sprite(_ image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .interpolation(.none) // nearest-neighbor → crisp pixels, no blur
            .frame(width: Self.size.width, height: Self.size.height)
    }

    /// Load every frame for a state; returns `[]` if any are missing so the
    /// caller falls back to the placeholder rather than showing a partial set.
    private static func loadFrames(for state: DogAnimationState) -> [NSImage] {
        let names = DogSprite.frameNames(for: state)
        let images = names.compactMap { NSImage(named: $0) }
        return images.count == names.count ? images : []
    }

    private static func frameIndex(at date: Date, count: Int) -> Int {
        let tick = Int(date.timeIntervalSinceReferenceDate * DogSprite.framesPerSecond)
        return ((tick % count) + count) % count
    }
}

/// Placeholder pixel-style dog drawn with SwiftUI shapes, used until real sprite
/// frames are added.
private struct PlaceholderDog: View {
    /// Waggle the ears only while the user is typing.
    let isTyping: Bool

    /// Peak ear swing, in degrees.
    private let earSwing: Double = 14
    /// Waggle oscillations per second.
    private let earCyclesPerSecond: Double = 1.5

    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.78, green: 0.58, blue: 0.36))
                .frame(width: 60, height: 40)
                .offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.82, green: 0.62, blue: 0.40))
                .frame(width: 42, height: 38)
                .offset(y: -14)

            // Ears
            ears
                .offset(y: -30)

            // Eyes
            HStack(spacing: 14) {
                eye
                eye
            }
            .offset(y: -16)

            // Nose
            Circle()
                .fill(Color.black)
                .frame(width: 7, height: 7)
                .offset(y: -4)
        }
    }

    /// Ears: continuously waggle (opposite directions) while typing, driven by a
    /// TimelineView so the motion is tied directly to `isTyping` and stops the
    /// instant typing ends. No repeatForever animation to get "stuck".
    @ViewBuilder
    private var ears: some View {
        if isTyping {
            TimelineView(.animation) { context in
                earsRow(angle: swingAngle(at: context.date))
            }
        } else {
            earsRow(angle: 0)
        }
    }

    private func earsRow(angle: Double) -> some View {
        HStack(spacing: 26) {
            ear(angle: angle)
            ear(angle: -angle)
        }
    }

    private func swingAngle(at date: Date) -> Double {
        let phase = date.timeIntervalSinceReferenceDate * earCyclesPerSecond * 2 * .pi
        return sin(phase) * earSwing
    }

    /// One ear, pivoting at its base so it swings like a flap.
    private func ear(angle: Double) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 0.55, green: 0.38, blue: 0.22))
            .frame(width: 14, height: 22)
            .rotationEffect(.degrees(angle), anchor: .bottom)
    }

    private var eye: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 6, height: 6)
    }
}

#Preview {
    DogSpriteView(animationState: .idle)
        .background(Color.gray.opacity(0.2))
}
