import SwiftUI
import AppKit

// Previews the placeholder-dog look. Run: swift scripts/preview_dog.swift

let bodyC = Color(red: 0.78, green: 0.58, blue: 0.36)
let headC = Color(red: 0.82, green: 0.62, blue: 0.40)
let earC = Color(red: 0.55, green: 0.38, blue: 0.22)
let tailC = Color(red: 0.62, green: 0.44, blue: 0.27)

let canvasW: CGFloat = 128
let canvasH: CGFloat = 120

struct DopeyDog: View {
    // Point the tail right to test clipping at the canvas edge.
    var tailAngle: Double = 70
    var body: some View {
        ZStack {
            // Tail — rounded rectangle, thinner
            RoundedRectangle(cornerRadius: 5).fill(tailC)
                .frame(width: 11, height: 18)
                .rotationEffect(.degrees(tailAngle), anchor: .bottom)
                .offset(x: 15, y: 6)

            // Legs — rounded rectangles
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 3).fill(bodyC).frame(width: 10, height: 11)
                RoundedRectangle(cornerRadius: 3).fill(bodyC).frame(width: 10, height: 11)
            }.offset(y: 25)

            // Body — smaller than the head (cuter)
            RoundedRectangle(cornerRadius: 8).fill(bodyC)
                .frame(width: 36, height: 24).offset(y: 16)

            // Head
            RoundedRectangle(cornerRadius: 16).fill(headC)
                .frame(width: 42, height: 38).offset(y: -5)

            earV.rotationEffect(.degrees(45), anchor: .top).offset(x: -12, y: -10)
            earV.rotationEffect(.degrees(-45), anchor: .top).offset(x: 12, y: -10)

            Circle().fill(.black).frame(width: 4, height: 4).offset(x: -12, y: -5)
            Circle().fill(.black).frame(width: 4, height: 4).offset(x: 12, y: -5)

            RoundedRectangle(cornerRadius: 2.5).fill(.black)
                .frame(width: 7, height: 4).offset(y: 0)
        }
        .frame(width: canvasW, height: canvasH)
        .border(.red.opacity(0.7))
    }
    var earV: some View {
        TaperedEar().fill(earC).frame(width: 13, height: 22)
    }
}

struct TaperedEar: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        // Narrow rounded top
        p.move(to: CGPoint(x: w * 0.22, y: 0))
        p.addQuadCurve(to: CGPoint(x: w * 0.78, y: 0),
                       control: CGPoint(x: w * 0.5, y: -h * 0.06))
        // Right side curving outward
        p.addQuadCurve(to: CGPoint(x: w, y: h * 0.75),
                       control: CGPoint(x: w * 1.08, y: h * 0.3))
        // Rounded bottom-right → bottom center
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: h),
                       control: CGPoint(x: w, y: h))
        // Rounded bottom center → bottom-left
        p.addQuadCurve(to: CGPoint(x: 0, y: h * 0.75),
                       control: CGPoint(x: 0, y: h))
        // Left side back to top
        p.addQuadCurve(to: CGPoint(x: w * 0.22, y: 0),
                       control: CGPoint(x: -w * 0.08, y: h * 0.3))
        p.closeSubpath()
        return p
    }
}

MainActor.assumeIsolated {
    let renderer = ImageRenderer(content: DopeyDog().padding(16).background(Color(white: 0.30)))
    renderer.scale = 3
    if let img = renderer.nsImage, let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
        try! png.write(to: URL(fileURLWithPath: "/tmp/dog_refined.png"))
        print("wrote")
    } else { print("render failed") }
}
