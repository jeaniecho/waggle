import AppKit

// Renders a monochrome dog-head silhouette for the menu bar (a template image).
// Black shape on transparent; macOS tints it for light/dark menu bars.
// Run: swift scripts/make_menubar_icon.swift

func render(_ size: CGFloat, to path: String) {
    let img = NSImage(size: NSSize(width: size, height: size))
    img.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    let k = size / 36.0
    NSColor.black.setFill()

    func rr(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, _ r: CGFloat) {
        NSBezierPath(roundedRect: NSRect(x: x * k, y: y * k, width: w * k, height: h * k),
                     xRadius: r * k, yRadius: r * k).fill()
    }
    func ear(baseX: CGFloat, baseY: CGFloat, angleDeg: CGFloat) {
        ctx.saveGState()
        ctx.translateBy(x: baseX * k, y: baseY * k)
        ctx.rotate(by: angleDeg * .pi / 180)
        NSBezierPath(roundedRect: NSRect(x: -3.5 * k, y: 0, width: 7 * k, height: 14 * k),
                     xRadius: 3 * k, yRadius: 3 * k).fill()
        ctx.restoreGState()
    }

    // Ears (tilted outward), then the head over their bases.
    ear(baseX: 12, baseY: 17, angleDeg: 26)
    ear(baseX: 24, baseY: 17, angleDeg: -26)
    rr(8, 7, 20, 18, 7)   // head

    // Punch out eyes so the silhouette reads as a face.
    ctx.saveGState()
    ctx.setBlendMode(.destinationOut)
    NSColor.black.setFill()
    NSBezierPath(ovalIn: NSRect(x: 13 * k, y: 15 * k, width: 3.2 * k, height: 3.6 * k)).fill()
    NSBezierPath(ovalIn: NSRect(x: 20 * k, y: 15 * k, width: 3.2 * k, height: 3.6 * k)).fill()
    ctx.restoreGState()

    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

render(18, to: "/tmp/menubar_dog.png")
render(36, to: "/tmp/menubar_dog@2x.png")
render(180, to: "/tmp/menubar_dog_preview.png") // big preview only
print("done")
