import SwiftUI

/// The app's Settings window (Cmd-,). Reads current values from the settings
/// store and routes every change through `AppEnvironment.perform`, the same path
/// the menu bar uses, so behaviour stays consistent and side effects apply live.
struct SettingsView: View {
    @ObservedObject var env: AppEnvironment

    private let focusOptions = [15, 20, 25, 30, 45, 50, 60]
    private let breakOptions = [5, 10, 15, 20]
    private let longBreakOptions = [10, 15, 20, 30]
    private let sessionsOptions = [2, 3, 4, 5, 6]
    private let stretchOptions = [20, 30, 45, 60, 90]

    var body: some View {
        TabView {
            general.tabItem { Label("General", systemImage: "gearshape") }
            productivity.tabItem { Label("Productivity", systemImage: "timer") }
            appearance.tabItem { Label("Appearance", systemImage: "paintpalette") }
            about.tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 440)
    }

    private var store: SettingsStore { env.settingsStore }

    // MARK: - General

    private var general: some View {
        Form {
            if env.launchItem.isAvailable {
                Toggle("Launch at login", isOn: bool(env.launchItem.isEnabled) { .setLaunchAtLogin($0) })
            }
            Toggle("Show notifications", isOn: bool(store.notificationsEnabled) { .setNotificationsEnabled($0) })

            Section("Reactions") {
                Toggle("Pause all reactions", isOn: bool(store.reactionsPaused) { .setReactionsPaused($0) })
                Toggle("React to cursor", isOn: bool(store.reactCursor) { .setReactCursor($0) })
                    .disabled(store.reactionsPaused)
                Toggle("React to typing", isOn: bool(store.reactTyping) { .setReactTyping($0) })
                    .disabled(store.reactionsPaused)
                if !env.permissionManager.isTrusted {
                    HStack {
                        Text("Typing reactions need Accessibility access.")
                            .foregroundColor(.secondary).font(.callout)
                        Button("Enable…") { env.perform(.openAccessibilitySettings) }
                    }
                }
            }
        }
        .padding(20)
    }

    // MARK: - Productivity

    private var productivity: some View {
        Form {
            Section("Stretch Reminder") {
                Toggle("Remind me to stretch", isOn: Binding(
                    get: { store.stretchEnabled },
                    set: { env.perform(.setStretchMinutes($0 ? store.stretchIntervalMinutes : 0)) }
                ))
                Picker("Every", selection: int(store.stretchIntervalMinutes) { .setStretchMinutes($0) }) {
                    ForEach(stretchOptions, id: \.self) { Text("\($0) min").tag($0) }
                }
                .disabled(!store.stretchEnabled)
            }

            Section("Pomodoro") {
                Picker("Focus", selection: int(store.pomodoroFocusMinutes) { .setFocusMinutes($0) }) {
                    ForEach(focusOptions, id: \.self) { Text("\($0) min").tag($0) }
                }
                Picker("Break", selection: int(store.pomodoroBreakMinutes) { .setBreakMinutes($0) }) {
                    ForEach(breakOptions, id: \.self) { Text("\($0) min").tag($0) }
                }
                Picker("Long break", selection: int(store.pomodoroLongBreakMinutes) { .setLongBreakMinutes($0) }) {
                    ForEach(longBreakOptions, id: \.self) { Text("\($0) min").tag($0) }
                }
                Picker("Long break after", selection: int(store.pomodoroSessionsBeforeLongBreak) { .setSessionsBeforeLongBreak($0) }) {
                    ForEach(sessionsOptions, id: \.self) { Text("\($0) sessions").tag($0) }
                }
            }
        }
        .padding(20)
    }

    // MARK: - Appearance

    private var appearance: some View {
        Form {
            Picker("Dog colour", selection: Binding(
                get: { store.dogCoatID },
                set: { env.perform(.setDogCoat($0)) }
            )) {
                ForEach(DogCoat.all) { Text($0.name).tag($0.id) }
            }
            .pickerStyle(.inline)
        }
        .padding(20)
    }

    // MARK: - About

    private var about: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable().frame(width: 64, height: 64)
            Text("Waggle").font(.title2).bold()
            Text("Version \(appVersion)").foregroundColor(.secondary)
            Text("A tiny desktop dog. 100% local — no tracking, no accounts.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    // MARK: - Binding helpers (route through env.perform)

    private func bool(_ get: @autoclosure @escaping () -> Bool, _ make: @escaping (Bool) -> MenuBarAction) -> Binding<Bool> {
        Binding(get: get, set: { env.perform(make($0)) })
    }

    private func int(_ get: @autoclosure @escaping () -> Int, _ make: @escaping (Int) -> MenuBarAction) -> Binding<Int> {
        Binding(get: get, set: { env.perform(make($0)) })
    }
}
