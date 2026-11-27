import AppKit
import SwiftUI

// Compile this with DogAnimationState.swift, DogCoat.swift, DogSprite.swift,
// and DogSpriteView.swift, then pass an output PNG path. The checked-in README
// preview is rendered from the same production view used by the app.
@main
struct RenderReadmeDemo {
    @MainActor
    static func main() throws {
        let outputPath = CommandLine.arguments.dropFirst().first ?? "docs/assets/waggle-states.png"
        let states: [(String, DogAnimationState)] = [
            ("Idle", .idle),
            ("Typing", .typing),
            ("Focus", .sleep),
            ("Break", .celebrate),
        ]

        let preview = HStack(spacing: 16) {
            ForEach(Array(states.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 4) {
                    DogSpriteView(
                        animationState: item.1,
                        previewRaisedEar: item.1 == .typing,
                        coat: .default
                    )
                    Text(item.0)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(Color(red: 0.12, green: 0.13, blue: 0.16))

        let renderer = ImageRenderer(content: preview)
        renderer.scale = 2
        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff),
            let png = bitmap.representation(using: .png, properties: [:])
        else {
            throw RenderError.failed
        }

        try png.write(to: URL(fileURLWithPath: outputPath))
    }

    enum RenderError: Error {
        case failed
    }
}
