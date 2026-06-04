import SwiftUI
import AppKit

// Previews the placeholder-dog look by rendering a SwiftUI view to a PNG.
// Run: swift scripts/preview_dog.swift  → /tmp/dog_refined.png

let bodyC = Color(red: 0.78, green: 0.58, blue: 0.36)
let headC = Color(red: 0.82, green: 0.62, blue: 0.40)
let earC = Color(red: 0.55, green: 0.38, blue: 0.22)
let tailC = Color(red: 0.62, green: 0.44, blue: 0.27)

// The original "dopey" boxy dog, with a couple of subtle develops.
struct DopeyDog: View {
    var body: some View {
        ZStack {
            // Tail
            RoundedRectangle(cornerRadius: 4).fill(tailC)
                .frame(width: 8, height: 24)
                .rotationEffect(.degrees(12), anchor: .bottom)
                .offset(x: 26, y: 2)

            // Body
            RoundedRectangle(cornerRadius: 8).fill(bodyC)
                .frame(width: 60, height: 40).offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8).fill(headC)
                .frame(width: 42, height: 38).offset(y: -14)

            // Ears (up, slightly splayed)
            earV.rotationEffect(.degrees(8), anchor: .bottom).offset(x: -13, y: -26)
            earV.rotationEffect(.degrees(-8), anchor: .bottom).offset(x: 13, y: -26)

            // Eyes — plain dopey dots, set a little wide
            Circle().fill(.black).frame(width: 7, height: 7).offset(x: -11, y: -15)
            Circle().fill(.black).frame(width: 7, height: 7).offset(x: 11, y: -15)

            // Nose
            Circle().fill(.black).frame(width: 7, height: 7).offset(y: -4)
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
