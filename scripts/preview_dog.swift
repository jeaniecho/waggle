import SwiftUI
import AppKit

// Previews the placeholder-dog look by rendering a SwiftUI view to a PNG.
// Run: swift scripts/preview_dog.swift  → /tmp/dog_refined.png

let bodyC = Color(red: 0.78, green: 0.58, blue: 0.36)
let headC = Color(red: 0.82, green: 0.62, blue: 0.40)
let earC = Color(red: 0.55, green: 0.38, blue: 0.22)
let tailC = Color(red: 0.62, green: 0.44, blue: 0.27)
let legC = Color(red: 0.72, green: 0.52, blue: 0.31)

/// A tapered tail: wide base, curved sides, softly tapered tip.
struct TaperedTail: Shape {
    func path(in r: CGRect) -> Path {
        let w = r.width, h = r.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.30, y: h))
        p.addLine(to: CGPoint(x: w * 0.70, y: h))                                   // wide base
        p.addQuadCurve(to: CGPoint(x: w * 0.55, y: 0), control: CGPoint(x: w * 1.0, y: h * 0.30))  // right → tip
        p.addQuadCurve(to: CGPoint(x: w * 0.45, y: 0), control: CGPoint(x: w * 0.5, y: -h * 0.06))  // rounded tip
        p.addQuadCurve(to: CGPoint(x: w * 0.30, y: h), control: CGPoint(x: w * 0.0, y: h * 0.30))   // left → base
        p.closeSubpath()
        return p
    }
}

struct DopeyDog: View {
    var body: some View {
        ZStack {
            // Tail
            TaperedTail().fill(tailC)
                .frame(width: 15, height: 26)
                .rotationEffect(.degrees(18), anchor: .bottom)
                .offset(x: 26, y: 3)

            // Legs (short, behind the body)
            HStack(spacing: 18) {
                Capsule().fill(legC).frame(width: 13, height: 16)
                Capsule().fill(legC).frame(width: 13, height: 16)
            }
            .offset(y: 33)

            // Body
            RoundedRectangle(cornerRadius: 8).fill(bodyC)
                .frame(width: 60, height: 40).offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8).fill(headC)
                .frame(width: 42, height: 38).offset(y: -14)

            // Ears (flopped ±45)
            earV.rotationEffect(.degrees(45), anchor: .top).offset(x: -13, y: -26)
            earV.rotationEffect(.degrees(-45), anchor: .top).offset(x: 13, y: -26)

            // Eyes
            Circle().fill(.black).frame(width: 7, height: 7).offset(x: -11, y: -16)
            Circle().fill(.black).frame(width: 7, height: 7).offset(x: 11, y: -16)

            // Nose — slightly flat (wider than tall)
            Ellipse().fill(.black).frame(width: 10, height: 6).offset(y: -4)
        }
        .frame(width: 96, height: 120)
    }

    var earV: some View {
        RoundedRectangle(cornerRadius: 4).fill(earC).frame(width: 14, height: 22)
    }
}

MainActor.assumeIsolated {
    let renderer = ImageRenderer(content: DopeyDog().padding(20).background(Color(white: 0.30)))
    renderer.scale = 3
    if let img = renderer.nsImage,
       let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        try! png.write(to: URL(fileURLWithPath: "/tmp/dog_refined.png"))
        print("wrote")
    } else {
        print("render failed")
    }
}
