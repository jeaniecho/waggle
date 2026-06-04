import AppKit

// Renders a monochrome dog-HEAD silhouette for the menu bar (a template image):
// a rounded head with two ears poking out to the sides, eyes + nose punched out.
// The canvas is narrow (30×36 grid) so the menu bar slot isn't wide, and the
// ears use the width instead of empty padding.
// Black on transparent; macOS tints for light/dark menu bars.
// Run: swift scripts/make_menubar_icon.swift

let W: CGFloat = 30
let H: CGFloat = 36

func render(scale: CGFloat, to path: String) {
    let img = NSImage(size: NSSize(width: W * scale, height: H * scale))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let k = scale
    NSColor.black.setFill()

    func rr(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) {
        NSBezierPath(roundedRect: NSRect(x: x * k, y: y * k, width: w * k, height: h * k),
                     xRadius: r * k, yRadius: r * k).fill()
    }
    func ear(baseX: CGFloat, baseY: CGFloat, angleDeg: CGFloat) {
        ctx.saveGState()
        ctx.translateBy(x: baseX * k, y: baseY * k)
        ctx.rotate(by: angleDeg * .pi / 180)
        NSBezierPath(roundedRect: NSRect(x: -2.7 * k, y: 0, width: 5.4 * k, height: 8.5 * k),
                     xRadius: 2.4 * k, yRadius: 2.4 * k).fill()
        ctx.restoreGState()
    }

    // Ears poking out to the sides, then the rounded head over their bases.
    ear(baseX: 9.5, baseY: 20.5, angleDeg: 62)
    ear(baseX: 20.5, baseY: 20.5, angleDeg: -62)
    rr(6.5, 8, 17, 16, 5) // head

    // Punch out eyes + nose so it reads as a face.
    ctx.saveGState()
    ctx.setBlendMode(.destinationOut)
    NSColor.black.setFill()
    NSBezierPath(ovalIn: NSRect(x: 10.6 * k, y: 14.6 * k, width: 3.3 * k, height: 3.5 * k)).fill() // left eye
    NSBezierPath(ovalIn: NSRect(x: 16.1 * k, y: 14.6 * k, width: 3.3 * k, height: 3.5 * k)).fill() // right eye
    NSBezierPath(ovalIn: NSRect(x: 13.4 * k, y: 10.6 * k, width: 3.2 * k, height: 2.9 * k)).fill()  // nose
    ctx.restoreGState()

    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

render(scale: 0.5, to: "/tmp/menubar_dog.png")   // 15×18 (@1x)
render(scale: 1.0, to: "/tmp/menubar_dog@2x.png") // 30×36 (@2x)
render(scale: 5.0, to: "/tmp/menubar_dog_preview.png")
print("done")
