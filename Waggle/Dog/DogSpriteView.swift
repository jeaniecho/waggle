import SwiftUI

/// Placeholder pixel-art dog drawn with SwiftUI shapes.
///
/// This is intentionally simple so behavior and architecture can be built
/// without final art. Real sprite frames replace this view in the sprite
/// pipeline task; keep the public surface (a fixed-size, transparent-background
/// view) stable so the swap is mechanical.
struct DogSpriteView: View {
    /// Logical canvas size of the dog. The overlay window sizes itself to this.
    static let size = CGSize(width: 96, height: 96)

    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.78, green: 0.58, blue: 0.36))
                .frame(width: 60, height: 40)
                .offset(y: 14)

            // Head
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.82, green: 0.62, blue: 0.40))
                .frame(width: 42, height: 38)
                .offset(y: -14)

            // Ears
            HStack(spacing: 26) {
                ear
                ear
            }
            .offset(y: -30)

            // Eyes
            HStack(spacing: 14) {
                eye
                eye
            }
            .offset(y: -16)

            // Nose
            Circle()
                .fill(Color.black)
                .frame(width: 7, height: 7)
                .offset(y: -4)
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }

    private var ear: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 0.55, green: 0.38, blue: 0.22))
            .frame(width: 14, height: 22)
    }

    private var eye: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 6, height: 6)
    }
}

#Preview {
    DogSpriteView()
        .background(Color.gray.opacity(0.2))
}
