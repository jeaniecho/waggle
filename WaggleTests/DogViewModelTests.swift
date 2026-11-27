import XCTest
@testable import Waggle

@MainActor
final class DogViewModelTests: XCTestCase {
    func testStatePriorityAndFallbackOrder() {
        let viewModel = DogViewModel()

        viewModel.updateCursor(direction: .left, excited: false, angle: 180)
        XCTAssertEqual(viewModel.state, .watchingCursor(direction: .left))

        viewModel.setTyping(true)
        XCTAssertEqual(viewModel.state, .typing)

        viewModel.setFocusing(true)
        XCTAssertEqual(viewModel.state, .focusing)

        viewModel.setBreakTime(true)
        XCTAssertEqual(viewModel.state, .breakTime)

        viewModel.setStretching(true)
        XCTAssertEqual(viewModel.state, .stretching)

        viewModel.setDragging(true)
        XCTAssertEqual(viewModel.state, .dragging)

        viewModel.setDragging(false)
        XCTAssertEqual(viewModel.state, .stretching)

        viewModel.setStretching(false)
        XCTAssertEqual(viewModel.state, .breakTime)

        viewModel.setBreakTime(false)
        XCTAssertEqual(viewModel.state, .focusing)

        viewModel.setFocusing(false)
        XCTAssertEqual(viewModel.state, .typing)

        viewModel.setTyping(false)
        XCTAssertEqual(viewModel.state, .watchingCursor(direction: .left))

        viewModel.updateCursor(direction: nil, excited: false, angle: nil)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testExcitedCursorMapsToTailWagAnimation() {
        let viewModel = DogViewModel()

        viewModel.updateCursor(direction: .upperRight, excited: true, angle: 45)

        XCTAssertEqual(viewModel.state, .excited)
        XCTAssertEqual(viewModel.animationState, .tailWag)
    }
}
