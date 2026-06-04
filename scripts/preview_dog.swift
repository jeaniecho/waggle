import SwiftUI
import AppKit

// Previews a refined placeholder-dog look by rendering a SwiftUI view to a PNG.
// Run: swift scripts/preview_dog.swift  → /tmp/dog_refined.png

let bodyC = Color(red: 0.80, green: 0.60, blue: 0.37)
let headC = Color(red: 0.84, green: 0.64, blue: 0.42)
let earC = Color(red: 0.56, green: 0.39, blue: 0.23)
let muzzleC = Color(red: 0.93, green: 0.84, blue: 0.70)
let tailC = Color(red: 0.64, green: 0.46, blue: 0.29)

struct RefinedDog: View {
    var body: some View {
        ZStack {
            // Tail
            RoundedRectangle(cornerRadius: 5).fill(tailC)
                .frame(width: 9, height: 22)
                .rotationEffect(.degrees(20), anchor: .bottom)
                .offset(x: 27, y: 4)

            // Body + chest patch
            RoundedRectangle(cornerRadius: 16).fill(bodyC)
                .frame(width: 62, height: 44).offset(y: 16)
            Ellipse().fill(muzzleC.opacity(0.6))
                .frame(width: 24, height: 26).offset(y: 22)

            // Front paws
            HStack(spacing: 16) {
                Capsule().fill(bodyC).frame(width: 14, height: 12)
                Capsule().fill(bodyC).frame(width: 14, height: 12)
            }.offset(y: 35)

            // Ears (behind head)
            earView(angle: 14, x: -16)
            earView(angle: -14, x: 16)

            // Head
            RoundedRectangle(cornerRadius: 18).fill(headC)
                .frame(width: 46, height: 42).offset(y: -13)

            // Muzzle
            Ellipse().fill(muzzleC)
                .frame(width: 30, height: 22).offset(y: -3)

            // Eyes
            eyeView(x: -10)
            eyeView(x: 10)

            // Nose
            Ellipse().fill(.black)
                .frame(width: 9, height: 7).offset(y: -8)
            // Mouth
            Path { p in
                p.move(to: CGPoint(x: 8, y: 0))
                p.addQuadCurve(to: CGPoint(x: 16, y: 5), control: CGPoint(x: 11, y: 5))
                p.move(to: CGPoint(x: 8, y: 0))
                p.addQuadCurve(to: CGPoint(x: 0, y: 5), control: CGPoint(x: 5, y: 5))
            }
            .stroke(Color.black.opacity(0.65), lineWidth: 1.6)
            .frame(width: 16, height: 6).offset(y: -1)
        }
        .frame(width: 96, height: 120)
    }

    func earView(angle: Double, x: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 7).fill(earC)
            .frame(width: 16, height: 26)
            .rotationEffect(.degrees(angle), anchor: .top)
            .offset(x: x, y: -28)
    }

    func eyeView(x: CGFloat) -> some View {
        ZStack {
            Circle().fill(.black).frame(width: 8, height: 8)
            Circle().fill(.white).frame(width: 2.6, height: 2.6).offset(x: 1.4, y: -1.4)
        }
        .offset(x: x, y: -16)
    }
}

MainActor.assumeIsolated {
    let renderer = ImageRenderer(content: RefinedDog().padding(20).background(Color(white: 0.30)))
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
