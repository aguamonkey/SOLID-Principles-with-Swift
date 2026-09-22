import Foundation

/// Shared list identity; each conforming value supplies its own stored identifier.
protocol IdentifiableWithStringID: Identifiable {
    var id: String { get }
}
