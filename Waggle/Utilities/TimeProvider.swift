import Foundation

/// Abstraction over "now" so timer-driven logic stays testable. Productivity
/// managers depend on this rather than calling `Date()` directly.
protocol TimeProvider {
    func now() -> Date
}

/// System clock implementation.
struct SystemTimeProvider: TimeProvider {
    func now() -> Date { Date() }
}
