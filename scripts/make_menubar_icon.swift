import AppKit

// Renders a monochrome dog-HEAD silhouette for the menu bar (a template image):
// a rounded head with two ears poking out to the sides, eyes + nose punched out.
// Narrow 30×36 design grid so the menu bar slot isn't wide.
//
// Draws into an explicitly-sized NSBitmapImageRep (not lockFocus, which doubles
// on Retina) so the @1x/@2x pixel sizes are exact: 15×18 and 30×36.
// Run: swift scripts/make_menubar_icon.swift

let W: CGFloat = 30
let H: CGFloat = 24       // cropped tight so the dog fills the frame (bigger in the bar)
let contentDropY: CGFloat = 6 // shift content down into the shorter canvas

func render(k: CGFloat, to path: String) {
    let pxW = Int((W * k).rounded())
    let pxH = Int((H * k).rounded())
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pxW, pixelsHigh: pxH,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    let gctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.current = gctx
    let ctx = gctx.cgContext
    ctx.translateBy(x: 0, y: -contentDropY * k) // recenter content in the shorter canvas
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

    NSGraphicsContext.restoreGraphicsState()
    let png = rep.representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: path))
}

render(k: 0.5, to: "/tmp/menubar_dog.png")    // 15×18 (@1x)
render(k: 1.0, to: "/tmp/menubar_dog@2x.png") // 30×36 (@2x)
render(k: 5.0, to: "/tmp/menubar_dog_preview.png")
print("done")
