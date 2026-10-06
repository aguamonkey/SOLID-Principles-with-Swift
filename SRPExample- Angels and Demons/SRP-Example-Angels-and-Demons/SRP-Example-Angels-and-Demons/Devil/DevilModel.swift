import Foundation

/// A figure's identity and description are independent of loading and SwiftUI.
struct DemonModel: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var ability: String

    func describeAbility() -> String {
        "\(name) wields the ability of \(ability)."
    }
}
