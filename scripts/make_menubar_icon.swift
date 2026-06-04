import AppKit

// Renders a monochrome dog-HEAD silhouette for the menu bar (a template image):
// rounded head, two straight (vertical) ears, eyes + nose punched out, centred
// with generous top/bottom padding so the system's rounded selection highlight
// reads nicely. Black on transparent; macOS tints for light/dark menu bars.
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

    // Straight (vertical) ears, then the rounded head over their bases.
    rr(11, 20, 5.6, 7.5, 2.4)  // left ear
    rr(19.4, 20, 5.6, 7.5, 2.4) // right ear
    rr(8.5, 9, 19, 15, 5)       // head — wider than tall, like the app

    // Punch out eyes + nose so it reads as a face.
    ctx.saveGState()
    ctx.setBlendMode(.destinationOut)
    NSColor.black.setFill()
    NSBezierPath(ovalIn: NSRect(x: 12.6 * k, y: 15.2 * k, width: 3.3 * k, height: 3.5 * k)).fill() // left eye
    NSBezierPath(ovalIn: NSRect(x: 20.1 * k, y: 15.2 * k, width: 3.3 * k, height: 3.5 * k)).fill() // right eye
    NSBezierPath(ovalIn: NSRect(x: 16.4 * k, y: 11.0 * k, width: 3.2 * k, height: 2.9 * k)).fill()  // nose
    ctx.restoreGState()

    img.unlockFocus()
    let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

render(18, to: "/tmp/menubar_dog.png")
render(36, to: "/tmp/menubar_dog@2x.png")
render(180, to: "/tmp/menubar_dog_preview.png")
print("done")
