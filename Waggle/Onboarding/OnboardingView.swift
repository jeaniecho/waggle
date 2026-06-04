import SwiftUI

/// One-time welcome shown on first launch. Explains what Waggle does, where to
/// find it, and offers the optional Accessibility step for typing reactions.
struct OnboardingView: View {
    let onEnableTyping: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable().frame(width: 72, height: 72)
            Text("Welcome to Waggle").font(.title).bold()
            Text("A tiny dog lives on your desktop. Drag it anywhere — it watches "
                 + "your cursor, naps during focus sessions, and reminds you to stretch.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Label("Find controls in the menu bar (the dog icon).", systemImage: "menubar.arrow.up.rectangle")
                Label("Everything runs locally — no tracking, no accounts.", systemImage: "lock.shield")
                Label("Optional: let the dog react when you type.", systemImage: "keyboard")
            }
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Button("Enable Typing Reactions") { onEnableTyping() }
                Button("Get Started") { onDone() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 6)
        }
        .padding(28)
        .frame(width: 440)
    }
}
