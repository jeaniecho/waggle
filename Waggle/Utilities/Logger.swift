import os

/// Lightweight namespaced logging wrapper over `os.Logger`. Privacy-preserving
/// by default: never log user input, text, or app/window identities.
enum Log {
    static let overlay = os.Logger(subsystem: "co.curelation.Waggle", category: "overlay")
    static let lifecycle = os.Logger(subsystem: "co.curelation.Waggle", category: "lifecycle")
}
