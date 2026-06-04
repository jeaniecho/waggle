import AppKit

// Renders a 1024×1024 master app icon: the full Waggle dog (body + head + ears +
// eyes + nose), matching the in-app PlaceholderDog, on a warm squircle.
// Run: swift scripts/make_icon.swift  → writes /tmp/waggle_icon_1024.png

let S: CGFloat = 1024
let image = NSImage(size: NSSize(width: S, height: S))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

// App dog colours (tan coat).
let bodyC = NSColor(srgbRed: 0.78, green: 0.58, blue: 0.36, alpha: 1)
let headC = NSColor(srgbRed: 0.82, green: 0.62, blue: 0.40, alpha: 1)
let earC  = NSColor(srgbRed: 0.55, green: 0.38, blue: 0.22, alpha: 1)
let tailC = NSColor(srgbRed: 0.62, green: 0.44, blue: 0.27, alpha: 1)

func roundedRect(_ rect: NSRect, _ radius: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}
func ellipse(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)).fill()
}

// Background squircle with a warm vertical gradient.
let bg = NSRect(x: 70, y: 70, width: S - 140, height: S - 140)
ctx.saveGState()
NSBezierPath(roundedRect: bg, xRadius: 200, yRadius: 200).addClip()
NSGradient(
    starting: NSColor(srgbRed: 1.00, green: 0.90, blue: 0.68, alpha: 1),
    ending:   NSColor(srgbRed: 0.96, green: 0.72, blue: 0.38, alpha: 1)
)!.draw(in: bg, angle: -90)
ctx.restoreGState()

// Map app dog coordinates (96-unit canvas, SwiftUI y-down) to the icon.
let k: CGFloat = 8                 // scale
let originX: CGFloat = 512
let originY: CGFloat = 478          // app y=0 maps here (AppKit y-up)
func cx(_ dx: CGFloat) -> CGFloat { originX + dx * k }
func cy(_ dy: CGFloat) -> CGFloat { originY - dy * k } // flip: SwiftUI down → AppKit up
// A rounded rect given the app's center offset (dx,dy) and size (w,h).
func dogRect(dx: CGFloat, dy: CGFloat, w: CGFloat, h: CGFloat, r: CGFloat, _ color: NSColor) {
    let rect = NSRect(x: cx(dx) - w * k / 2, y: cy(dy) - h * k / 2, width: w * k, height: h * k)
    roundedRect(rect, r * k, color)
}

// Tail (behind body), a stubby shape poking up-right.
ctx.saveGState()
ctx.translateBy(x: cx(28), y: cy(6))
ctx.rotate(by: -32 * .pi / 180)
roundedRect(NSRect(x: -4 * k, y: 0, width: 8 * k, height: 22 * k), 4 * k, tailC)
ctx.restoreGState()

// Body
dogRect(dx: 0, dy: 14, w: 60, h: 40, r: 8, bodyC)

// Ears (behind the head), tilted outward from base points near the head top.
func drawEar(baseDX: CGFloat, baseDY: CGFloat, angleDeg: CGFloat) {
    ctx.saveGState()
    ctx.translateBy(x: cx(baseDX), y: cy(baseDY))
    ctx.rotate(by: angleDeg * .pi / 180)
    roundedRect(NSRect(x: -7 * k, y: 0, width: 14 * k, height: 24 * k), 6 * k, earC)
    ctx.restoreGState()
}
drawEar(baseDX: -13, baseDY: -20, angleDeg: 22)
drawEar(baseDX: 13, baseDY: -20, angleDeg: -22)

// Head
dogRect(dx: 0, dy: -14, w: 42, h: 38, r: 8, headC)

// Eyes
ellipse(cx: cx(-10), cy: cy(-16), w: 7.5 * k, h: 8 * k, .black)
ellipse(cx: cx(10), cy: cy(-16), w: 7.5 * k, h: 8 * k, .black)

// Nose
ellipse(cx: cx(0), cy: cy(-4), w: 8 * k, h: 6.5 * k, .black)

image.unlockFocus()

let tiff = image.tiffRepresentation!
let rep = NSBitmapImageRep(data: tiff)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "/tmp/waggle_icon_1024.png"))
print("wrote /tmp/waggle_icon_1024.png")
