import SwiftUI

/// Detail presentation delegates descriptive wording to the model.
struct DemonDetailView: View {
    let demon: DemonModel
    var body: some View {
        GuidePlate(name: demon.name, attribute: demon.ability,
                   description: demon.describeAbility(), symbol: "moon")
    }
}
