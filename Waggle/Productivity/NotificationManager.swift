import UserNotifications

/// Thin wrapper over `UNUserNotificationCenter` for the stretch/Pomodoro
/// reminders. Generic reminders only — no user content (privacy).
@MainActor
final class NotificationManager {
    private let center = UNUserNotificationCenter.current()
    private var authorized = false

    /// Ask once; if denied, `notify` simply does nothing.
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            Task { @MainActor in self?.authorized = granted }
        }
    }

    func notify(_ body: String) {
        guard authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = "Waggle"
        content.body = body
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: content, trigger: nil
        )
        center.add(request)
    }
}
