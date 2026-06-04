import AppKit

// Renders a monochrome dog-HEAD silhouette for the menu bar (a template image),
// matching the app dog's head: rounded head, two ears splayed up-and-out, with
// eyes + nose punched out. Centred with even top/bottom padding.
// Black shape on transparent; macOS tints it for light/dark menu bars.
// Run: swift scripts/make_menubar_icon.swift

func render(_ size: CGFloat, to path: String) {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let k = size / 36.0 // design on a 36-unit grid
    NSColor.black.setFill()

    func rr(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) {
        NSBezierPath(roundedRect: NSRect(x: x * k, y: y * k, width: w * k, height: h * k),
                     xRadius: r * k, yRadius: r * k).fill()
    }
    func ear(baseX: CGFloat, baseY: CGFloat, angleDeg: CGFloat) {
        ctx.saveGState()
        ctx.translateBy(x: baseX * k, y: baseY * k)
        ctx.rotate(by: angleDeg * .pi / 180)
        NSBezierPath(roundedRect: NSRect(x: -3.4 * k, y: 0, width: 6.8 * k, height: 11 * k),
                     xRadius: 3 * k, yRadius: 3 * k).fill()
        ctx.restoreGState()
    }

    // Ears (tilted outward), then the rounded head over their bases.
    ear(baseX: 12, baseY: 20.5, angleDeg: 25)
    ear(baseX: 24, baseY: 20.5, angleDeg: -25)
    rr(7, 5, 22, 19, 6) // head — wider than tall, like the app

    // Punch out eyes + nose so it reads as a face.
    ctx.saveGState()
    ctx.setBlendMode(.destinationOut)
    NSColor.black.setFill()
    NSBezierPath(ovalIn: NSRect(x: 11.4 * k, y: 14.6 * k, width: 3.6 * k, height: 3.8 * k)).fill() // left eye
    NSBezierPath(ovalIn: NSRect(x: 21.0 * k, y: 14.6 * k, width: 3.6 * k, height: 3.8 * k)).fill() // right eye
    NSBezierPath(ovalIn: NSRect(x: 16.2 * k, y: 9.4 * k, width: 3.6 * k, height: 3.2 * k)).fill()  // nose
    ctx.restoreGState()

    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

render(18, to: "/tmp/menubar_dog.png")
render(36, to: "/tmp/menubar_dog@2x.png")
render(180, to: "/tmp/menubar_dog_preview.png")
print("done")
