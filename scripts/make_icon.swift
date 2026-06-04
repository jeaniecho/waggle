import AppKit

// Renders a 1024×1024 master app icon: a tan dog face on a warm squircle.
// Run: swift scripts/make_icon.swift  → writes /tmp/waggle_icon_1024.png

let S: CGFloat = 1024
let image = NSImage(size: NSSize(width: S, height: S))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext

func roundedRect(_ rect: NSRect, _ radius: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}
func ellipse(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat, _ color: NSColor) {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: cx - w / 2, y: cy - h / 2, width: w, height: h)).fill()
}

let head = NSColor(srgbRed: 0.82, green: 0.60, blue: 0.36, alpha: 1)
let ear = NSColor(srgbRed: 0.56, green: 0.38, blue: 0.21, alpha: 1)
let snout = NSColor(srgbRed: 0.93, green: 0.84, blue: 0.71, alpha: 1)
let tongue = NSColor(srgbRed: 0.92, green: 0.36, blue: 0.45, alpha: 1)

// Background squircle with a warm vertical gradient.
let bg = NSRect(x: 70, y: 70, width: S - 140, height: S - 140)
ctx.saveGState()
NSBezierPath(roundedRect: bg, xRadius: 200, yRadius: 200).addClip()
NSGradient(
    starting: NSColor(srgbRed: 1.00, green: 0.90, blue: 0.68, alpha: 1),
    ending:   NSColor(srgbRed: 0.96, green: 0.72, blue: 0.38, alpha: 1)
)!.draw(in: bg, angle: -90)
ctx.restoreGState()

// Ears (behind the head), drawn from a base point and tilted outward.
func drawEar(baseX: CGFloat, baseY: CGFloat, angleDeg: CGFloat) {
    ctx.saveGState()
    ctx.translateBy(x: baseX, y: baseY)
    ctx.rotate(by: angleDeg * .pi / 180)
    roundedRect(NSRect(x: -68, y: 0, width: 136, height: 230), 60, ear)
    ctx.restoreGState()
}
drawEar(baseX: 512 - 150, baseY: 560, angleDeg: 24)
drawEar(baseX: 512 + 150, baseY: 560, angleDeg: -24)

// Head
roundedRect(NSRect(x: 277, y: 250, width: 470, height: 440), 150, head)

// Snout patch (lighter), lower-center of the face
ellipse(cx: 512, cy: 400, w: 300, h: 230, snout)

// Eyes
ellipse(cx: 512 - 110, cy: 540, w: 78, h: 98, .black)
ellipse(cx: 512 + 110, cy: 540, w: 78, h: 98, .black)
// Eye glints
ellipse(cx: 512 - 92, cy: 562, w: 24, h: 28, .white)
ellipse(cx: 512 + 128, cy: 562, w: 24, h: 28, .white)

// Nose
ellipse(cx: 512, cy: 430, w: 110, h: 80, .black)

// Tongue (sticking out below the snout)
roundedRect(NSRect(x: 512 - 42, y: 250, width: 84, height: 120), 38, tongue)
// Re-draw the lower snout edge over the tongue's top so it tucks under the mouth
ellipse(cx: 512, cy: 380, w: 300, h: 200, snout)
// Mouth line hint: nose already implies it; keep clean.

image.unlockFocus()

let tiff = image.tiffRepresentation!
let rep = NSBitmapImageRep(data: tiff)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "/tmp/waggle_icon_1024.png"))
print("wrote /tmp/waggle_icon_1024.png")
