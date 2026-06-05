import SwiftUI

struct SettingsView: View {
    @ObservedObject var env: AppEnvironment

    private let focusOptions     = [15, 20, 25, 30, 45, 50, 60]
    private let breakOptions     = [5, 10, 15, 20]
    private let longBreakOptions = [10, 15, 20, 30]
    private let sessionsOptions  = [2, 3, 4, 5, 6]
    private let stretchOptions   = [20, 30, 45, 60, 90]

    var body: some View {
        TabView {
            general     .tabItem { Label("General",      systemImage: "gearshape") }
            productivity.tabItem { Label("Productivity", systemImage: "timer") }
            appearance  .tabItem { Label("Appearance",   systemImage: "paintpalette") }
            about       .tabItem { Label("About",        systemImage: "info.circle") }
        }
        .frame(width: 460)
    }

    private var store: SettingsStore { env.settingsStore }

    // MARK: - General

    private var general: some View {
        ScrollView {
            VStack(spacing: 16) {
                settingsCard {
                    if env.launchItem.isAvailable {
                        row { Toggle("Launch at Login", isOn: bool(env.launchItem.isEnabled) { .setLaunchAtLogin($0) }) }
                        divider
                    }
                    row { Toggle("Show Notifications", isOn: bool(store.notificationsEnabled) { .setNotificationsEnabled($0) }) }
                }

                settingsSection("Reactions") {
                    row { Toggle("Pause All Reactions", isOn: bool(store.reactionsPaused) { .setReactionsPaused($0) }) }
                    divider
                    row { Toggle("React to Cursor", isOn: bool(store.reactCursor) { .setReactCursor($0) }) }
                        .disabled(store.reactionsPaused)
                    divider
                    row { Toggle("React to Typing", isOn: bool(store.reactTyping) { .setReactTyping($0) }) }
                        .disabled(store.reactionsPaused)
                }

                if !env.permissionManager.isTrusted {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.raised.fill").foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accessibility Access Required")
                                .font(.callout).bold()
                            Text("Needed for typing reactions.")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Enable…") { env.perform(.openAccessibilitySettings) }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(10)
                }
            }
            .padding(20)
        }
    }

    // MARK: - Productivity

    private var productivity: some View {
        ScrollView {
            VStack(spacing: 16) {
                settingsSection("Stretch Reminder") {
                    row {
                        Toggle("Enabled", isOn: Binding(
                            get: { store.stretchEnabled },
                            set: { env.perform(.setStretchMinutes($0 ? store.stretchIntervalMinutes : 0)) }
                        ))
                    }
                    divider
                    row {
                        Picker("Interval", selection: int(store.stretchIntervalMinutes) { .setStretchMinutes($0) }) {
                            ForEach(stretchOptions, id: \.self) { Text("\($0) min").tag($0) }
                        }
                    }
                    .disabled(!store.stretchEnabled)
                }

                settingsSection("Pomodoro") {
                    row {
                        Picker("Focus Duration", selection: int(store.pomodoroFocusMinutes) { .setFocusMinutes($0) }) {
                            ForEach(focusOptions, id: \.self) { Text("\($0) min").tag($0) }
                        }
                    }
                    divider
                    row {
                        Picker("Short Break", selection: int(store.pomodoroBreakMinutes) { .setBreakMinutes($0) }) {
                            ForEach(breakOptions, id: \.self) { Text("\($0) min").tag($0) }
                        }
                    }
                    divider
                    row {
                        Picker("Long Break", selection: int(store.pomodoroLongBreakMinutes) { .setLongBreakMinutes($0) }) {
                            ForEach(longBreakOptions, id: \.self) { Text("\($0) min").tag($0) }
                        }
                    }
                    divider
                    row {
                        Picker("Long Break After", selection: int(store.pomodoroSessionsBeforeLongBreak) { .setSessionsBeforeLongBreak($0) }) {
                            ForEach(sessionsOptions, id: \.self) { Text("\($0) sessions").tag($0) }
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Appearance

    private var appearance: some View {
        ScrollView {
            VStack(spacing: 16) {
                settingsSection("Dog Colour") {
                    ForEach(Array(DogCoat.all.enumerated()), id: \.offset) { idx, coat in
                        if idx > 0 { divider }
                        HStack(spacing: 10) {
                            ZStack {
                                Circle().fill(coat.body).frame(width: 18, height: 18)
                                Circle().fill(coat.head).frame(width: 10, height: 10).offset(y: -4)
                            }
                            Text(coat.name)
                            Spacer()
                            if store.dogCoatID == coat.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture { env.perform(.setDogCoat(coat.id)) }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - About

    private var about: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 72, height: 72)
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)

                VStack(spacing: 4) {
                    Text("Waggle").font(.title2).bold()
                    Text("Version \(appVersion)").foregroundColor(.secondary)
                }

                Text("A tiny desktop dog.\nLocal-first — no tracking, no accounts.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(28)
    }

    // MARK: - Layout helpers

    private func settingsCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption).fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            settingsCard(content)
        }
    }

    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
    }

    private var divider: some View {
        Divider().padding(.leading, 14)
    }

    // MARK: - Binding helpers

    private func bool(_ get: @autoclosure @escaping () -> Bool, _ make: @escaping (Bool) -> MenuBarAction) -> Binding<Bool> {
        Binding(get: get, set: { env.perform(make($0)) })
    }

    private func int(_ get: @autoclosure @escaping () -> Int, _ make: @escaping (Int) -> MenuBarAction) -> Binding<Int> {
        Binding(get: get, set: { env.perform(make($0)) })
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}
