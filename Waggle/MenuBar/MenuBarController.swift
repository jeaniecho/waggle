import AppKit

/// Snapshot of the state the menu needs to render (checkmarks, labels).
struct MenuBarState {
    var pomodoroActive: Bool
    var overlayVisible: Bool
    var coatID: String
    var focusMinutes: Int
    var breakMinutes: Int
    var stretchMinutes: Int
    var stretchEnabled: Bool
    var reactionsPaused: Bool
    var reactCursor: Bool
    var reactTyping: Bool
    var launchAtLogin: Bool
    var launchAvailable: Bool
}

/// Owns the status-bar item and its menu. This is a thin shell: it builds the
/// menu and emits `MenuBarAction`s; the routing to manager methods lives in the
/// composition root (`AppEnvironment`) so there is no duplicated logic here.
///
/// The menu is rebuilt each time it opens so it reflects current state.
@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let onAction: (MenuBarAction) -> Void
    private let state: () -> MenuBarState

    private let focusOptions = [15, 20, 25, 30, 45, 50, 60]
    private let breakOptions = [5, 10, 15, 20]
    private let stretchOptions = [20, 30, 45, 60, 90]

    private let statusItem: NSStatusItem
    private let menu = NSMenu()

    init(
        onAction: @escaping (MenuBarAction) -> Void,
        state: @escaping () -> MenuBarState
    ) {
        self.onAction = onAction
        self.state = state
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        super.init()

        configureButton()
        menu.delegate = self
        statusItem.menu = menu
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        if let dog = NSImage(named: "MenuBarDog") {
            dog.isTemplate = true // tint for light/dark menu bars
            button.image = dog
        } else if let sf = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "Waggle") {
            button.image = sf
        } else {
            button.title = "🐾"
        }
        button.toolTip = "Waggle"
    }

    // MARK: - NSMenuDelegate

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let s = state()

        if s.pomodoroActive {
            addItem("Stop Pomodoro", .stopPomodoro)
        } else {
            addItem("Start Pomodoro", .startPomodoro)
        }
        addItem("Reset Stretch Timer", .resetStretchTimer)

        menu.addItem(.separator())

        addCheckItem("Pause Reactions", checked: s.reactionsPaused, .setReactionsPaused(!s.reactionsPaused))

        menu.addItem(.separator())

        if s.overlayVisible {
            addItem("Hide Waggle", .hideWaggle)
        } else {
            addItem("Show Waggle", .showWaggle)
        }

        menu.addItem(.separator())

        addDogColorMenu(selected: s.coatID)
        addMinutesMenu("Focus Duration", focusOptions, current: s.focusMinutes) { .setFocusMinutes($0) }
        addMinutesMenu("Break Duration", breakOptions, current: s.breakMinutes) { .setBreakMinutes($0) }
        addStretchMenu(current: s.stretchMinutes, enabled: s.stretchEnabled)
        addReactionsMenu(cursor: s.reactCursor, typing: s.reactTyping)
        if s.launchAvailable {
            addCheckItem("Launch at Login", checked: s.launchAtLogin, .setLaunchAtLogin(!s.launchAtLogin))
        }

        menu.addItem(.separator())

        addItem("Settings…", .openSettings, keyEquivalent: ",")
        addItem("Open Accessibility Settings…", .openAccessibilitySettings)

        menu.addItem(.separator())

        addItem("Quit Waggle", .quit, keyEquivalent: "q")
    }

    private func addCheckItem(_ title: String, checked: Bool, _ action: MenuBarAction) {
        let item = NSMenuItem(title: title, action: #selector(handle(_:)), keyEquivalent: "")
        item.target = self
        item.representedObject = action
        item.state = checked ? .on : .off
        menu.addItem(item)
    }

    /// "Reactions" submenu: per-reaction on/off toggles.
    private func addReactionsMenu(cursor: Bool, typing: Bool) {
        let submenu = NSMenu()
        for (title, on, action) in [
            ("Cursor", cursor, MenuBarAction.setReactCursor(!cursor)),
            ("Typing", typing, MenuBarAction.setReactTyping(!typing))
        ] {
            let item = NSMenuItem(title: title, action: #selector(handle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = action
            item.state = on ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: "Reactions", action: nil, keyEquivalent: "")
        parent.submenu = submenu
        menu.addItem(parent)
    }

    /// A "Dog Color" submenu listing the coats, with a checkmark on the current.
    private func addDogColorMenu(selected: String) {
        let submenu = NSMenu()
        for coat in DogCoat.all {
            let item = NSMenuItem(title: coat.name, action: #selector(handle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = MenuBarAction.setDogCoat(coat.id)
            item.state = (coat.id == selected) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: "Dog Color", action: nil, keyEquivalent: "")
        parent.submenu = submenu
        menu.addItem(parent)
    }

    /// A minutes submenu (e.g. Focus/Break Duration), checking the current value.
    private func addMinutesMenu(
        _ title: String, _ options: [Int], current: Int,
        action: (Int) -> MenuBarAction
    ) {
        let submenu = NSMenu()
        for m in options {
            let item = NSMenuItem(title: "\(m) min", action: #selector(handle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = action(m)
            item.state = (m == current) ? .on : .off
            submenu.addItem(item)
        }
        let parent = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        parent.submenu = submenu
        menu.addItem(parent)
    }

    /// The "Stretch Reminder" submenu: Off + interval choices.
    private func addStretchMenu(current: Int, enabled: Bool) {
        let submenu = NSMenu()

        let off = NSMenuItem(title: "Off", action: #selector(handle(_:)), keyEquivalent: "")
        off.target = self
        off.representedObject = MenuBarAction.setStretchMinutes(0)
        off.state = enabled ? .off : .on
        submenu.addItem(off)
        submenu.addItem(.separator())

        for m in stretchOptions {
            let item = NSMenuItem(title: "Every \(m) min", action: #selector(handle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = MenuBarAction.setStretchMinutes(m)
            item.state = (enabled && m == current) ? .on : .off
            submenu.addItem(item)
        }

        let parent = NSMenuItem(title: "Stretch Reminder", action: nil, keyEquivalent: "")
        parent.submenu = submenu
        menu.addItem(parent)
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
