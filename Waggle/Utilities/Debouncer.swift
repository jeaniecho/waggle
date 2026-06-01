import Foundation

/// Coalesces rapid calls into a single trailing action after a quiet interval.
/// Used later to keep the typing reaction active while keys keep coming, and
/// available now for any debounced work. Main-actor bound for UI safety.
@MainActor
final class Debouncer {
    private let interval: TimeInterval
    private var workItem: DispatchWorkItem?

    init(interval: TimeInterval) {
        self.interval = interval
    }

    /// Schedule `action`, cancelling any pending call from a previous `call`.
    func call(_ action: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: action)
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: item)
    }

    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
