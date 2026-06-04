import SwiftUI

/// A selectable dog coat colour, providing the shades the placeholder dog uses
/// for its body, head, ears, tail, and lighter muzzle/belly patch.
struct DogCoat: Identifiable, Equatable {
    let id: String   // stable key used for persistence + menu state
    let name: String // menu label
    let body: Color
    let head: Color
    let ear: Color
    let tail: Color
    let muzzle: Color

    /// All selectable coats, in menu order.
    static let all: [DogCoat] = [tan, golden, gray, cream, chocolate, charcoal]

    static let `default` = tan

    /// Look up a coat by id, falling back to the default.
    static func coat(id: String) -> DogCoat {
        all.first { $0.id == id } ?? .default
    }

    static let tan = DogCoat(
        id: "tan", name: "Tan",
        body: Color(red: 0.80, green: 0.60, blue: 0.37),
        head: Color(red: 0.84, green: 0.64, blue: 0.42),
        ear: Color(red: 0.56, green: 0.39, blue: 0.23),
        tail: Color(red: 0.64, green: 0.46, blue: 0.29),
        muzzle: Color(red: 0.93, green: 0.84, blue: 0.70)
    )

    static let golden = DogCoat(
        id: "golden", name: "Golden",
        body: Color(red: 0.90, green: 0.72, blue: 0.42),
        head: Color(red: 0.94, green: 0.77, blue: 0.47),
        ear: Color(red: 0.74, green: 0.54, blue: 0.28),
        tail: Color(red: 0.82, green: 0.62, blue: 0.34),
        muzzle: Color(red: 0.98, green: 0.91, blue: 0.76)
    )

    static let gray = DogCoat(
        id: "gray", name: "Gray",
        body: Color(red: 0.60, green: 0.61, blue: 0.66),
        head: Color(red: 0.66, green: 0.67, blue: 0.72),
        ear: Color(red: 0.44, green: 0.45, blue: 0.50),
        tail: Color(red: 0.50, green: 0.51, blue: 0.56),
        muzzle: Color(red: 0.85, green: 0.86, blue: 0.89)
    )

    static let cream = DogCoat(
        id: "cream", name: "Cream",
        body: Color(red: 0.93, green: 0.89, blue: 0.81),
        head: Color(red: 0.96, green: 0.93, blue: 0.86),
        ear: Color(red: 0.78, green: 0.72, blue: 0.61),
        tail: Color(red: 0.84, green: 0.79, blue: 0.69),
        muzzle: Color(red: 0.99, green: 0.97, blue: 0.93)
    )

    static let chocolate = DogCoat(
        id: "chocolate", name: "Chocolate",
        body: Color(red: 0.48, green: 0.32, blue: 0.20),
        head: Color(red: 0.53, green: 0.36, blue: 0.23),
        ear: Color(red: 0.34, green: 0.22, blue: 0.13),
        tail: Color(red: 0.40, green: 0.27, blue: 0.16),
        muzzle: Color(red: 0.80, green: 0.67, blue: 0.55)
    )

    static let charcoal = DogCoat(
        id: "charcoal", name: "Charcoal",
        body: Color(red: 0.30, green: 0.30, blue: 0.34),
        head: Color(red: 0.36, green: 0.36, blue: 0.40),
        ear: Color(red: 0.19, green: 0.19, blue: 0.23),
        tail: Color(red: 0.24, green: 0.24, blue: 0.28),
        muzzle: Color(red: 0.56, green: 0.57, blue: 0.62)
    )
}
