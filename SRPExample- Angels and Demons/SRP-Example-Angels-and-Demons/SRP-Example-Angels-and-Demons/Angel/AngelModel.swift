import Foundation

/// A figure's identity and description are independent of loading and SwiftUI.
struct AngelModel: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var power: String

    func describePower() -> String {
        "\(name) possesses the power of \(power)."
    }
}
