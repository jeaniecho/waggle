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
                .frame(width: 11, height: 26)
                .rotationEffect(.degrees(tailAngle), anchor: .bottom)
                .offset(x: 15, y: 6)

            // Legs — rounded rectangles
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4).fill(bodyC).frame(width: 12, height: 16)
                RoundedRectangle(cornerRadius: 4).fill(bodyC).frame(width: 12, height: 16)
            }.offset(y: 29)

            // Body — smaller than the head (cuter)
            RoundedRectangle(cornerRadius: 8).fill(bodyC)
                .frame(width: 36, height: 24).offset(y: 16)

            // Head
            RoundedRectangle(cornerRadius: 8).fill(headC)
                .frame(width: 42, height: 38).offset(y: -14)

            // Ears — slightly thicker (13 wide), flopped ±45, nudged down
            earV.rotationEffect(.degrees(45), anchor: .top).offset(x: -14, y: -23)
            earV.rotationEffect(.degrees(-45), anchor: .top).offset(x: 14, y: -23)

            // Eyes — smaller, set a touch farther apart
            Circle().fill(.black).frame(width: 5, height: 5).offset(x: -12, y: -13)
            Circle().fill(.black).frame(width: 5, height: 5).offset(x: 12, y: -13)

            // Nose — rounded rectangle, flatter
            RoundedRectangle(cornerRadius: 2.5).fill(.black)
                .frame(width: 10, height: 5).offset(y: -4)
        }
        .frame(width: canvasW, height: canvasH)
        .border(.red.opacity(0.7)) // canvas (window) edge
    }
    var earV: some View {
        RoundedRectangle(cornerRadius: 5).fill(earC).frame(width: 13, height: 22)
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
