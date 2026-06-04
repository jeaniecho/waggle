import AppKit

/// Owns the status-bar item and its menu. This is a thin shell: it builds the
/// menu and emits `MenuBarAction`s; the routing to manager methods lives in the
/// composition root (`AppEnvironment`) so there is no duplicated logic here.
///
/// The menu is rebuilt each time it opens so the Pomodoro and visibility items
/// reflect current state.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let onAction: (MenuBarAction) -> Void
    private let isPomodoroActive: () -> Bool
    private let isOverlayVisible: () -> Bool

    private let statusItem: NSStatusItem
    private let menu = NSMenu()

    init(
        onAction: @escaping (MenuBarAction) -> Void,
        isPomodoroActive: @escaping () -> Bool,
        isOverlayVisible: @escaping () -> Bool
    ) {
        self.onAction = onAction
        self.isPomodoroActive = isPomodoroActive
        self.isOverlayVisible = isOverlayVisible
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        super.init()

        configureButton()
        menu.delegate = self
        statusItem.menu = menu
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        if let image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "Waggle") {
            button.image = image
        } else {
            button.title = "🐾"
        }
        button.toolTip = "Waggle"
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()

        if isPomodoroActive() {
            addItem("Stop Pomodoro", .stopPomodoro)
        } else {
            addItem("Start Pomodoro", .startPomodoro)
        }
        addItem("Reset Stretch Timer", .resetStretchTimer)

        menu.addItem(.separator())

        if isOverlayVisible() {
            addItem("Hide Waggle", .hideWaggle)
        } else {
            addItem("Show Waggle", .showWaggle)
        }

        menu.addItem(.separator())

        addItem("Open Accessibility Settings…", .openAccessibilitySettings)

        menu.addItem(.separator())

        addItem("Quit Waggle", .quit, keyEquivalent: "q")
    }

    // MARK: - Helpers

    private func addItem(_ title: String, _ action: MenuBarAction, keyEquivalent: String = "") {
        let item = NSMenuItem(title: title, action: #selector(handle(_:)), keyEquivalent: keyEquivalent)
        item.target = self
        item.representedObject = action
        menu.addItem(item)
    }

    @objc private func handle(_ sender: NSMenuItem) {
        guard let action = sender.representedObject as? MenuBarAction else { return }
        onAction(action)
    }

    deinit {
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
