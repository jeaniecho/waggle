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
    private let earSwing: Double = 18
    /// Full left-then-right alternations per second.
    private let earCyclesPerSecond: Double = 1.5
    /// Time over which the ears ease back to rest after typing stops.
    private let windDown: TimeInterval = 0.45

    /// Whether the waggle timeline runs (true while typing and during wind-down).
    @State private var active = false
    /// When the wind-down began; nil while typing.
    @State private var windDownStart: Date?
    /// Pending "stop the timeline" work, cancelled if typing resumes.
    @State private var stopItem: DispatchWorkItem?

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
        .onAppear { sync(typing: isTyping) }
        .onChange(of: isTyping) { sync(typing: $0) }
    }

    /// Ears alternate (one flaps while the other rests) while typing; when typing
    /// stops they ease back to rest, then the timeline halts.
    @ViewBuilder
    private var ears: some View {
        if active {
            TimelineView(.animation) { context in
                let amp = amplitude(at: context.date)
                earsRow(
                    left: leftAngle(at: context.date) * amp,
                    right: rightAngle(at: context.date) * amp
                )
            }
        } else {
            earsRow(left: 0, right: 0)
        }
    }

    private func earsRow(left: Double, right: Double) -> some View {
        HStack(spacing: 26) {
            ear(angle: left)
            ear(angle: right)
        }
    }

    // MARK: - Animation driving

    /// Start waggling on typing; on stop, ramp down then halt the timeline.
    private func sync(typing: Bool) {
        stopItem?.cancel()
        stopItem = nil

        if typing {
            windDownStart = nil
            active = true
        } else if active {
            windDownStart = Date()
            let item = DispatchWorkItem {
                active = false
                windDownStart = nil
            }
            stopItem = item
            DispatchQueue.main.asyncAfter(deadline: .now() + windDown, execute: item)
        }
    }

    /// 1 while typing; ramps 1 → 0 over the wind-down so the ears settle to rest.
    private func amplitude(at date: Date) -> Double {
        guard let start = windDownStart else { return 1 }
        return max(0, 1 - date.timeIntervalSince(start) / windDown)
    }

    private func phase(at date: Date) -> Double {
        date.timeIntervalSinceReferenceDate * earCyclesPerSecond * 2 * .pi
    }

    /// Left ear flaps up during the first half of each cycle, rests otherwise.
    private func leftAngle(at date: Date) -> Double {
        max(sin(phase(at: date)), 0) * earSwing
    }

    /// Right ear flaps (opposite direction) during the other half — alternating.
    private func rightAngle(at date: Date) -> Double {
        -max(-sin(phase(at: date)), 0) * earSwing
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
