import SwiftUI
import AppKit

// Previews the placeholder-dog look. Run: swift scripts/preview_dog.swift

let bodyC = Color(red: 0.78, green: 0.58, blue: 0.36)
let headC = Color(red: 0.82, green: 0.62, blue: 0.40)
let earC = Color(red: 0.55, green: 0.38, blue: 0.22)
let tailC = Color(red: 0.62, green: 0.44, blue: 0.27)

let canvasW: CGFloat = 128
let canvasH: CGFloat = 120

struct TaperedTail: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.30, y: h))
        p.addLine(to: CGPoint(x: w * 0.70, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.55, y: 0), control: CGPoint(x: w, y: h * 0.30))
        p.addQuadCurve(to: CGPoint(x: w * 0.45, y: 0), control: CGPoint(x: w * 0.5, y: -h * 0.06))
        p.addQuadCurve(to: CGPoint(x: w * 0.30, y: h), control: CGPoint(x: 0, y: h * 0.30))
        p.closeSubpath()
        return p
    }
}

struct DopeyDog: View {
    // Point the tail right to test clipping at the canvas edge.
    var tailAngle: Double = 70
    var body: some View {
        ZStack {
            TaperedTail().fill(tailC)
                .frame(width: 15, height: 26)
                .rotationEffect(.degrees(tailAngle), anchor: .bottom)
                .offset(x: 26, y: 3)

            HStack(spacing: 18) {
                Capsule().fill(bodyC).frame(width: 13, height: 16)
                Capsule().fill(bodyC).frame(width: 13, height: 16)
            }.offset(y: 30)

            // Body — flatter
            RoundedRectangle(cornerRadius: 8).fill(bodyC)
                .frame(width: 62, height: 34).offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8).fill(headC)
                .frame(width: 42, height: 38).offset(y: -14)

            // Ears — thinner (11 wide), flopped ±45
            earV.rotationEffect(.degrees(45), anchor: .top).offset(x: -13, y: -26)
            earV.rotationEffect(.degrees(-45), anchor: .top).offset(x: 13, y: -26)

            Circle().fill(.black).frame(width: 7, height: 7).offset(x: -11, y: -16)
            Circle().fill(.black).frame(width: 7, height: 7).offset(x: 11, y: -16)

            // Nose — rounded rectangle
            RoundedRectangle(cornerRadius: 2.5).fill(.black)
                .frame(width: 11, height: 6).offset(y: -4)
        }
        .frame(width: canvasW, height: canvasH)
        .border(.red.opacity(0.7)) // canvas (window) edge
    }
    var earV: some View {
        RoundedRectangle(cornerRadius: 4).fill(earC).frame(width: 11, height: 22)
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
