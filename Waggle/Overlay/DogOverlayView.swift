import SwiftUI

/// SwiftUI root hosted inside the overlay window. Keeps the window's content a
/// thin wrapper around the dog so the window can size itself to the dog.
///
/// A right-click context menu exposes the Accessibility permission status and a
/// way to open System Settings. (A fuller menu-bar control arrives in Task
/// 008; the dog's drag is left-button only, so a right-click menu does not
/// interfere with it.)
struct DogOverlayView: View {
    @ObservedObject var dogViewModel: DogViewModel
    @ObservedObject var permission: AccessibilityPermissionManager
    @ObservedObject var stretch: StretchReminderManager
    @ObservedObject var pomodoro: PomodoroManager

    var body: some View {
        DogSpriteView()
            // Transparent background so only the dog is visible; the whole
            // frame is still hit-testable so the dog can be dragged anywhere.
            .background(Color.clear)
            .contentShape(Rectangle())
            .contextMenu {
                if pomodoro.isActive {
                    Text(pomodoroStatus)
                    if pomodoro.isPaused {
                        Button("Resume Pomodoro") { pomodoro.resume() }
                    } else {
                        Button("Pause Pomodoro") { pomodoro.pause() }
                    }
                    Button("Stop Pomodoro") { pomodoro.stop() }
                } else {
                    Button("Start Pomodoro") { pomodoro.start() }
                }
                Divider()
                if stretch.isStretchDue {
                    Text("Time to stretch! 🐕")
                }
                Button("Reset stretch timer") {
                    stretch.reset()
                }
                Divider()
                if permission.isTrusted {
                    Text("Keyboard reactions: Enabled")
                } else {
                    Text("Keyboard reactions need Accessibility access")
                    Button("Open Accessibility Settings…") {
                        permission.openSystemSettings()
                    }
                }
            }
    }

    /// Human-readable Pomodoro status, e.g. "Focusing — 24:13".
    private var pomodoroStatus: String {
        switch pomodoro.state {
        case .idle: return ""
        case .focusing(let seconds): return "Focusing — \(Self.clock(seconds))"
        case .breakTime(let seconds): return "Break — \(Self.clock(seconds))"
        case .paused: return "Pomodoro paused"
        }
    }

    private static func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
