import SwiftUI

/// App entry point.
///
/// Waggle is a desktop overlay app: the visible UI is an AppKit panel created
/// by `AppDelegate`, not a SwiftUI scene. We therefore declare only a
/// `Settings` scene so SwiftUI still installs the standard app menu (giving us
/// a working Cmd-Q) without opening a document window at launch.
@main
struct WaggleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
