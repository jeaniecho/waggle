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
    /// Extra height above the dog leaves room for the sauna steam during focus.
    static let size = CGSize(width: 96, height: 120)

    var animationState: DogAnimationState = .idle
    /// Increments once per keystroke; the placeholder flaps an ear on each change.
    var keyPulse: Int = 0
    /// Increments when "?" is typed; the placeholder tilts its head.
    var tiltPulse: Int = 0
    /// Increments when "!" is typed; the placeholder jumps.
    var jumpPulse: Int = 0
    /// The dog's coat colour.
    var coat: DogCoat = .default

    var body: some View {
        content
            .frame(width: Self.size.width, height: Self.size.height)
    }

    @ViewBuilder
    private var content: some View {
        let frames = Self.loadFrames(for: animationState)
        if frames.isEmpty {
            PlaceholderDog(
                keyPulse: keyPulse,
                animationState: animationState,
                tiltPulse: tiltPulse,
                jumpPulse: jumpPulse,
                coat: coat
            )
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
///
/// Pomodoro flavour:
/// - focus (`.sleep`): a sauna towel on the head + rising steam, eyes relaxed.
/// - break (`.celebrate`): tongue out, happy eyes (the window also runs across
///   the screen — see DogOverlayWindowController).
private struct PlaceholderDog: View {
    /// Increments once per keystroke; each change flaps one ear.
    let keyPulse: Int
    /// Current visual state, used for the Pomodoro flavour.
    let animationState: DogAnimationState
    /// Increments when a "?" is typed; each change makes the dog tilt its head.
    let tiltPulse: Int
    /// Increments when a "!" is typed; each change makes the dog jump once.
    let jumpPulse: Int
    /// Coat colour shades for body / head / ears / tail.
    let coat: DogCoat

    /// Peak ear flap angle, in degrees.
    private let earSwing: Double = 45

    @State private var leftAngle: Double = 0
    @State private var rightAngle: Double = 0
    /// Which ear flaps on the next keystroke (ears alternate).
    @State private var flapLeftNext = true

    /// Head-tilt angle (degrees) for the "?" reaction.
    @State private var tilt: Double = 0
    @State private var tiltLeftNext = true

    /// Vertical offset for the "!" jump reaction.
    @State private var jumpOffset: Double = 0

    private var isFocusing: Bool { animationState == .sleep }
    private var isBreak: Bool { animationState == .celebrate }
    private var isStretching: Bool { animationState == .stretch }
    /// Tail wags happily when watching the cursor or on break.
    private var isWagging: Bool { animationState == .tailWag || animationState == .celebrate }

    private let towelColor = Color(white: 0.97)

    var body: some View {
        // The timeline is paused (no constant redraw) unless the stretch reminder
        // is active; while stretching, the whole dog scales up and down.
        TimelineView(.animation(paused: !isStretching)) { context in
            dogContent
                .scaleEffect(stretchScale(at: context.date), anchor: .center)
        }
    }

    private var dogContent: some View {
        ZStack {
            // Tail (behind the body)
            tail

            // Body
            RoundedRectangle(cornerRadius: 8)
                .fill(coat.body)
                .frame(width: 60, height: 40)
                .offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8)
                .fill(coat.head)
                .frame(width: 42, height: 38)
                .offset(y: -14)

            // Ears
            HStack(spacing: 26) {
                ear(angle: leftAngle)
                ear(angle: rightAngle)
            }
            .offset(y: -26)

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

            // Tongue (break: panting happily)
            if isBreak {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.93, green: 0.36, blue: 0.45))
                    .frame(width: 8, height: 7)
                    .offset(y: 3)
            }

            // Sauna towel + steam (focus)
            if isFocusing {
                saunaTowel
                steam
            }
        }
        .rotationEffect(.degrees(tilt), anchor: UnitPoint(x: 0.5, y: 0.72))
        .offset(y: jumpOffset)
        .onChange(of: keyPulse) { _ in flap() }
        .onChange(of: tiltPulse) { _ in headTilt() }
        .onChange(of: jumpPulse) { _ in jump() }
    }

    /// Stretch-reminder pulse: 1× when idle; while active, slowly scales taller
    /// and a touch narrower to grab attention (anchored at centre).
    private func stretchScale(at date: Date) -> CGSize {
        guard isStretching else { return CGSize(width: 1, height: 1) }
        let s = 0.5 - 0.5 * cos(date.timeIntervalSinceReferenceDate * 2.6) // 0…1
        return CGSize(width: 1 - 0.18 * s, height: 1 + 0.42 * s)
    }

    /// A "!" was typed: hop up and land with a little bounce.
    private func jump() {
        withAnimation(.easeOut(duration: 0.15)) { jumpOffset = -22 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { jumpOffset = 0 }
        }
    }

    /// A "?" was typed: cock the head to one side, hold briefly, then return.
    private func headTilt() {
        let dir = tiltLeftNext ? 1.0 : -1.0
        tiltLeftNext.toggle()
        withAnimation(.easeInOut(duration: 0.16)) { tilt = 15 * dir }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeInOut(duration: 0.22)) { tilt = 0 }
        }
    }

    // MARK: - Tail

    @ViewBuilder
    private var tail: some View {
        if isWagging {
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                tailShape(angle: sin(t * 7) * 24)
            }
        } else {
            tailShape(angle: 10)
        }
    }

    private func tailShape(angle: Double) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(coat.tail)
            .frame(width: 8, height: 24)
            .rotationEffect(.degrees(angle), anchor: .bottom)
            .offset(x: 26, y: 2)
    }

    // MARK: - Ear flap (typing)

    /// One keystroke → one ear flap, alternating ears. Runs in every state,
    /// including Pomodoro focus/break.
    private func flap() {
        let isLeft = flapLeftNext
        flapLeftNext.toggle()

        let target = isLeft ? earSwing : -earSwing // ears flap outward, opposite ways
        withAnimation(.easeOut(duration: 0.07)) {
            if isLeft { leftAngle = target } else { rightAngle = target }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            withAnimation(.easeIn(duration: 0.11)) {
                if isLeft { leftAngle = 0 } else { rightAngle = 0 }
            }
        }
    }

    /// One ear, pivoting at its base so it swings like a flap.
    private func ear(angle: Double) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(coat.ear)
            .frame(width: 14, height: 22)
            .rotationEffect(.degrees(angle), anchor: .top)
    }

    @ViewBuilder
    private var eye: some View {
        if isFocusing {
            // relaxed, closed eyes
            Capsule().fill(Color.black).frame(width: 7, height: 2)
        } else {
            Circle().fill(Color.black).frame(width: 6, height: 6)
        }
    }

    // MARK: - Sauna towel (focus)

    private var saunaTowel: some View {
        // A straight towel band laid across the head.
        RoundedRectangle(cornerRadius: 4)
            .fill(towelColor)
            .frame(width: 31, height: 14)
            .offset(y: -30)
    }

    // MARK: - Steam (focus)

    private var steam: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                steamPuff(t: t, offset: 0.0, x: -7)
                steamPuff(t: t, offset: 0.6, x: 6)
                steamPuff(t: t, offset: 1.2, x: -1)
            }
        }
    }

    /// A single steam puff that rises from the head and fades to nothing before
    /// it reaches the top of the canvas (so it never looks clipped).
    private func steamPuff(t: Double, offset: Double, x: Double) -> some View {
        let period = 1.8
        let local = ((t + offset).truncatingRemainder(dividingBy: period)) / period // 0…1
        let y = -36.0 - local * 16.0          // rise kept short so the puff stays in bounds
        let opacity = sin(local * .pi) * 0.45 // fades in then fully out by the top
        let size = 7.0 + local * 4.0
        let wiggle = sin(local * .pi * 2) * 3
        return Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: size, height: size)
            .blur(radius: 1.5)
            .offset(x: x + wiggle, y: y)
    }
}

#Preview {
    DogSpriteView(animationState: .idle)
        .background(Color.gray.opacity(0.2))
}
