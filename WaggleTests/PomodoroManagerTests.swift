import XCTest
@testable import Waggle

@MainActor
final class PomodoroManagerTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "PomodoroManagerTests")!
        defaults.removePersistentDomain(forName: "PomodoroManagerTests")
        defaults.set(1, forKey: UserDefaultsKeys.pomodoroFocusMinutes)
        defaults.set(1, forKey: UserDefaultsKeys.pomodoroBreakMinutes)
        defaults.set(1, forKey: UserDefaultsKeys.pomodoroLongBreakMinutes)
        defaults.set(2, forKey: UserDefaultsKeys.pomodoroSessionsBeforeLongBreak)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "PomodoroManagerTests")
        defaults = nil
        super.tearDown()
    }

    func testShortBreakLongBreakAndCompletionTransitions() {
        let dog = DogViewModel()
        let manager = PomodoroManager(
            settingsStore: SettingsStore(defaults: defaults),
            dogViewModel: dog
        )
        var events: [PomodoroEvent] = []
        manager.onEvent = { events.append($0) }

        manager.start()
        XCTAssertEqual(manager.state, .focusing(remainingSeconds: 60))
        XCTAssertEqual(dog.state, .focusing)

        advance(manager, seconds: 60)
        XCTAssertEqual(manager.state, .breakTime(remainingSeconds: 60))
        XCTAssertEqual(manager.completedSessions, 1)
        XCTAssertEqual(dog.state, .breakTime)
        XCTAssertEqual(events, [.breakStarted(isLong: false)])

        advance(manager, seconds: 60)
        XCTAssertEqual(manager.state, .focusing(remainingSeconds: 60))
        XCTAssertEqual(dog.state, .focusing)
        XCTAssertEqual(events.last, .focusStarted)

        advance(manager, seconds: 60)
        XCTAssertEqual(manager.state, .breakTime(remainingSeconds: 60))
        XCTAssertEqual(manager.completedSessions, 2)
        XCTAssertEqual(events.last, .breakStarted(isLong: true))

        advance(manager, seconds: 60)
        XCTAssertEqual(manager.state, .idle)
        XCTAssertEqual(manager.completedSessions, 0)
        XCTAssertEqual(dog.state, .idle)
        XCTAssertEqual(events.last, .finished)
    }

    func testPauseAndResumePreserveRemainingTime() {
        let manager = PomodoroManager(
            settingsStore: SettingsStore(defaults: defaults),
            dogViewModel: DogViewModel()
        )

        manager.start()
        advance(manager, seconds: 12)
        manager.pause()
        XCTAssertEqual(manager.state, .paused)

        manager.resume()
        XCTAssertEqual(manager.state, .focusing(remainingSeconds: 48))
        manager.stop()
    }

    private func advance(_ manager: PomodoroManager, seconds: Int) {
        for _ in 0..<seconds {
            manager.advanceOneSecond()
        }
    }
}
