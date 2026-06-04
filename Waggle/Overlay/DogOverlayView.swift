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
        ZStack {
            DogSpriteView(
                animationState: dogViewModel.animationState,
                keyPulse: dogViewModel.keyPressCount
            )
            if pomodoro.isActive {
                pomodoroOverlay
            }
        }
            .frame(width: DogSpriteView.size.width, height: DogSpriteView.size.height)
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
                    Text("Ears waggle when you type — needs Accessibility access")
                    Button("Enable typing reactions…") {
                        permission.promptForAccessibility()
                    }
                }
            }
    }

    /// Progress ring + countdown shown around the dog while a Pomodoro runs.
    /// Orange for focus, green for break; dims while paused.
    private var pomodoroOverlay: some View {
        let color = phaseColor
        return ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: 4)
            Circle()
                .trim(from: 0, to: pomodoro.remainingFraction)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: pomodoro.remainingFraction)

            VStack {
                Spacer()
                Text(pomodoroClock)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(color))
            }
        }
        .padding(2)
        .opacity(pomodoro.isPaused ? 0.55 : 1)
    }

    private var phaseColor: Color {
        switch pomodoro.state {
        case .breakTime: return .green
        default: return .orange // focusing or paused
        }
    }

    private var pomodoroClock: String {
        switch pomodoro.state {
        case .focusing(let seconds), .breakTime(let seconds): return Self.clock(seconds)
        case .paused: return "Paused"
        case .idle: return ""
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
