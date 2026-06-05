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
    /// Extra height above leaves room for the sauna steam; extra width keeps the
    /// cursor-following tail from being clipped when it points sideways.
    static let size = CGSize(width: 128, height: 120)

    var animationState: DogAnimationState = .idle
    /// Increments once per keystroke; the placeholder flaps an ear on each change.
    var keyPulse: Int = 0
    /// Increments when "?" is typed; the placeholder tilts its head.
    var tiltPulse: Int = 0
    /// Increments when "!" is typed; the placeholder jumps.
    var jumpPulse: Int = 0
    /// Angle to the cursor (degrees) for the tail to follow; nil if far.
    var cursorAngle: Double?
    /// Whether the dog is carrying a fetched bone.
    var hasBone: Bool = false
    /// The dog's coat colour.
    var coat: DogCoat = .default
    /// Increments on left-click; flaps the left ear.
    var leftEarPulse: Int = 0
    /// Increments on right-click; flaps the right ear.
    var rightEarPulse: Int = 0
    /// True while the user is dragging the dog.
    var isBeingDragged: Bool = false

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
                cursorAngle: cursorAngle,
                hasBone: hasBone,
                coat: coat,
                leftEarPulse: leftEarPulse,
                rightEarPulse: rightEarPulse,
                isBeingDragged: isBeingDragged
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
    /// Increments once per keystroke; each change flaps one ear (alternating).
    let keyPulse: Int
    /// Current visual state, used for the Pomodoro flavour.
    let animationState: DogAnimationState
    /// Increments when a "?" is typed; each change makes the dog tilt its head.
    let tiltPulse: Int
    /// Increments when a "!" is typed; each change makes the dog jump once.
    let jumpPulse: Int
    /// Angle to the cursor (degrees) the tail follows; nil if far.
    let cursorAngle: Double?
    /// Whether the dog is carrying a fetched bone (drawn at its mouth).
    let hasBone: Bool
    /// Coat colour shades for body / head / ears / tail.
    let coat: DogCoat
    /// Increments on left-click; forces left ear to flap.
    let leftEarPulse: Int
    /// Increments on right-click; forces right ear to flap.
    let rightEarPulse: Int
    /// True while the user is actively dragging the dog.
    let isBeingDragged: Bool

    /// Peak ear flap swing, in degrees.
    private let earSwing: Double = 45
    /// Default ear angle: the ears rest flopped at the flap-max position.
    private let earRest: Double = 35

    @State private var leftAngle: Double = 0
    @State private var rightAngle: Double = 0
    /// Which ear flaps on the next keystroke (ears alternate).
    @State private var flapLeftNext = true

    /// Head-tilt angle (degrees) for the "?" reaction.
    @State private var tilt: Double = 0
    @State private var tiltLeftNext = true

    /// Vertical offset for the "!" jump reaction.
    @State private var jumpOffset: Double = 0
    /// Brief eye-close for the occasional blink.
    @State private var blinking = false
    /// Animated tail base angle (follows the cursor in full 360°, eases to rest).
    /// Kept continuous (unwrapped) so it never snaps when crossing ±180°.
    @State private var tailBase: Double = 8
    private let tailRest: Double = 8

    private var isFocusing: Bool  { animationState == .sleep }
    private var isBreak: Bool     { animationState == .celebrate }
    private var isStretching: Bool { animationState == .stretch }
    private var isDragging: Bool  { isBeingDragged }
    private var isDrowsy: Bool    { animationState == .drowsy }
    private var isSleeping: Bool  { animationState == .sleeping }
    private var isWagging: Bool   { animationState == .tailWag || animationState == .celebrate }

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

            // Legs (short paws poking out below the body)
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 3).fill(coat.body).frame(width: 10, height: 11)
                RoundedRectangle(cornerRadius: 3).fill(coat.body).frame(width: 10, height: 11)
            }
            .offset(y: 25)

            // Body — smaller than the head (cuter)
            RoundedRectangle(cornerRadius: 12)
                .fill(coat.body)
                .frame(width: 36, height: 24)
                .offset(y: 16)

            // Head group — only this part tilts on "?"
            headGroup
        }
        .offset(y: jumpOffset)
        .onChange(of: keyPulse)      { _ in flapAlternating() }
        .onChange(of: leftEarPulse)  { _ in flapEar(isLeft: true) }
        .onChange(of: rightEarPulse) { _ in flapEar(isLeft: false) }
        .onChange(of: tiltPulse) { _ in headTilt() }
        .onChange(of: jumpPulse) { _ in jump() }
        .onChange(of: cursorAngle) { updateTailFollow($0) }
        .onChange(of: isBeingDragged) { dragging in
            if !dragging {
                // Ease tail back to rest when drag ends.
                withAnimation(.easeInOut(duration: 0.5)) { tailBase = unwrapped(tailRest) }
            }
        }
        .onAppear { scheduleBlink() }
    }

    /// Head, ears, eyes, nose and accessories — isolated so only these tilt on "?".
    private var headGroup: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(coat.head)
                .frame(width: 42, height: 38)
                .offset(y: -5)

            ear(angle: earRest + leftAngle).offset(x: -14, y: -9)
            ear(angle: -earRest + rightAngle).offset(x: 14, y: -9)

            // Blush
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.60).opacity(0.20))
                .frame(width: 6, height: 6)
                .offset(x: -14, y: 6)
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.60).opacity(0.20))
                .frame(width: 6, height: 6)
                .offset(x: 14, y: 6)

            eye.offset(x: -12, y: 1)
            eye.offset(x: 12, y: 1)

            Capsule()
                .fill(Color.black)
                .frame(width: 7, height: 5)
                .offset(y: 6)

            if isBreak {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.93, green: 0.36, blue: 0.45))
                    .frame(width: 8, height: 7)
                    .offset(y: 3)
            }

            if hasBone { bone }

            if isFocusing {
                saunaTowel
                steam
            }

            if isSleeping { zzz }
        }
        // Drowsy: head droops slightly; sleeping: more.
        .offset(y: isSleeping ? 4 : (isDrowsy ? 2 : 0))
        // Pivot at the neck (bottom of head), canvas is 120pt tall, neck ≈ 69pt from top.
        .frame(width: 128, height: 120)
        .rotationEffect(.degrees(tilt), anchor: UnitPoint(x: 0.5, y: 0.575))
    }

    /// Blink occasionally so the resting dog feels alive. Reschedules itself —
    /// one lightweight timer, no continuous redraw.
    private func scheduleBlink() {
        let delay = Double.random(in: 2.8 ... 6.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            blinking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { blinking = false }
            scheduleBlink()
        }
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

    /// A "?" was typed: quickly cock the head to one side, hold briefly, snap back.
    private func headTilt() {
        let dir = tiltLeftNext ? 1.0 : -1.0
        tiltLeftNext.toggle()
        withAnimation(.easeOut(duration: 0.08)) { tilt = 10 * dir }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.28)) { tilt = 0 }
        }
    }

    // MARK: - Tail

    @ViewBuilder
    private var tail: some View {
        if isDragging {
            // Spin 360° continuously while being dragged.
            TimelineView(.animation) { context in
                tailShape(angle: context.date.timeIntervalSinceReferenceDate * 360 * 1.5)
            }
        } else if cursorAngle == nil, isWagging {
            // Break: happy wag.
            TimelineView(.animation) { context in
                tailShape(angle: sin(context.date.timeIntervalSinceReferenceDate * 7) * 30)
            }
        } else {
            // Following the cursor (full 360°, eased) or resting.
            tailShape(angle: tailBase)
        }
    }

    /// Point the tail toward the cursor (any direction, taking the short way), or
    /// ease back to rest when far.
    private func updateTailFollow(_ angle: Double?) {
        guard !isDragging else { return } // spinning during drag; ignore cursor
        if let angle {
            let target = 90 - angle // clockwise rotation from "up" toward the cursor
            withAnimation(.easeOut(duration: 0.18)) { tailBase = unwrapped(target) }
        } else {
            withAnimation(.easeInOut(duration: 0.5)) { tailBase = unwrapped(tailRest) }
        }
    }

    /// The multiple of `target` (±360·k) nearest the current tailBase, so the
    /// tail rotates the short way and accumulates a full turn as the cursor circles.
    private func unwrapped(_ target: Double) -> Double {
        var t = target
        while t - tailBase > 180 { t -= 360 }
        while t - tailBase < -180 { t += 360 }
        return t
    }

    /// A little dog bone, carried at the mouth.
    private var bone: some View {
        let c = Color(white: 0.95)
        return ZStack {
            Capsule().fill(c).frame(width: 17, height: 5)
            Circle().fill(c).frame(width: 7, height: 7).offset(x: -8.5, y: -3)
            Circle().fill(c).frame(width: 7, height: 7).offset(x: -8.5, y: 3)
            Circle().fill(c).frame(width: 7, height: 7).offset(x: 8.5, y: -3)
            Circle().fill(c).frame(width: 7, height: 7).offset(x: 8.5, y: 3)
        }
        .offset(y: 12)
    }

    private func tailShape(angle: Double) -> some View {
        TaperedTail()
            .fill(coat.tail)
            .frame(width: 8, height: 15)
            .rotationEffect(.degrees(angle), anchor: .bottom)
            .offset(x: 11, y: 6)
    }

    // MARK: - Ear flap

    private func flapAlternating() {
        let isLeft = flapLeftNext
        flapLeftNext.toggle()
        flapEar(isLeft: isLeft)
    }

    /// Perk one ear up from its flopped rest, then drop it back.
    private func flapEar(isLeft: Bool) {
        let target = isLeft ? earSwing : -earSwing
        withAnimation(.easeOut(duration: 0.07)) {
            if isLeft { leftAngle = target } else { rightAngle = target }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            withAnimation(.easeIn(duration: 0.11)) {
                if isLeft { leftAngle = 0 } else { rightAngle = 0 }
            }
        }
    }

    /// One ear, pivoting at its top so it swings like a flap.
    private func ear(angle: Double) -> some View {
        TaperedEar()
            .fill(coat.ear)
            .frame(width: 13, height: 22)
            .rotationEffect(.degrees(angle), anchor: .top)
    }

    @ViewBuilder
    private var eye: some View {
        if isFocusing || blinking || isSleeping {
            // closed: focus, blink, petting, sleeping
            Capsule().fill(Color.black).frame(width: 6, height: 1.5)
        } else if isDrowsy {
            // half-closed: droopy capsule
            Capsule().fill(Color.black).frame(width: 6, height: 2.5)
        } else {
            Circle().fill(Color.black).frame(width: 4, height: 4)
        }
    }

    // MARK: - Zzz (sleeping)

    private var zzz: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            ZStack {
                zPuff(t: t, offset: 0.0, scale: 0.7, x:  12, baseY: -28)
                zPuff(t: t, offset: 0.8, scale: 0.9, x:  18, baseY: -34)
                zPuff(t: t, offset: 1.6, scale: 1.1, x:  24, baseY: -40)
            }
        }
    }

    private func zPuff(t: Double, offset: Double, scale: Double, x: Double, baseY: Double) -> some View {
        let period = 2.4
        let local = ((t + offset).truncatingRemainder(dividingBy: period)) / period
        let y = baseY - local * 10
        let opacity = sin(local * .pi) * 0.75
        return Text("z")
            .font(.system(size: 10 * scale, weight: .bold))
            .foregroundColor(Color.white.opacity(opacity))
            .offset(x: x, y: y)
    }

    // MARK: - Sauna towel (focus)

    private var saunaTowel: some View {
        // A straight towel band laid across the head.
        RoundedRectangle(cornerRadius: 4)
            .fill(towelColor)
            .frame(width: 31, height: 14)
            .offset(y: -26)
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

/// Tail shape: wide rounded base (attachment), curves in to narrow rounded tip.
private struct TaperedTail: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        let cr: CGFloat = w * 0.35
        var p = Path()
        p.move(to: CGPoint(x: cr, y: h))
        p.addQuadCurve(to: CGPoint(x: 0, y: h - cr), control: CGPoint(x: 0, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.30, y: 0),
                       control: CGPoint(x: -w * 0.05, y: h * 0.35))
        p.addQuadCurve(to: CGPoint(x: w * 0.70, y: 0),
                       control: CGPoint(x: w * 0.5, y: -h * 0.06))
        p.addQuadCurve(to: CGPoint(x: w, y: h - cr),
                       control: CGPoint(x: w * 1.05, y: h * 0.35))
        p.addQuadCurve(to: CGPoint(x: w - cr, y: h), control: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}

/// Ear shape: narrow rounded top (attachment), curves out to wider rounded bottom (tip).
private struct TaperedEar: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.22, y: 0))
        p.addQuadCurve(to: CGPoint(x: w * 0.78, y: 0),
                       control: CGPoint(x: w * 0.5, y: -h * 0.06))
        p.addQuadCurve(to: CGPoint(x: w, y: h * 0.75),
                       control: CGPoint(x: w * 1.08, y: h * 0.3))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h),
                       control: CGPoint(x: w, y: h))
        p.addQuadCurve(to: CGPoint(x: 0, y: h * 0.75),
                       control: CGPoint(x: 0, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.22, y: 0),
                       control: CGPoint(x: -w * 0.08, y: h * 0.3))
        p.closeSubpath()
        return p
    }
}

#Preview {
    DogSpriteView(animationState: .idle)
        .background(Color.gray.opacity(0.2))
}
