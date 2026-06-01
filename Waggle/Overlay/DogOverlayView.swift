import SwiftUI

/// SwiftUI root hosted inside the overlay window. Keeps the window's content a
/// thin wrapper around the dog so the window can size itself to the dog.
struct DogOverlayView: View {
    @ObservedObject var dogViewModel: DogViewModel

    var body: some View {
        DogSpriteView()
            // Transparent background so only the dog is visible; the whole
            // frame is still hit-testable so the dog can be dragged anywhere.
            .background(Color.clear)
            .contentShape(Rectangle())
    }
}
