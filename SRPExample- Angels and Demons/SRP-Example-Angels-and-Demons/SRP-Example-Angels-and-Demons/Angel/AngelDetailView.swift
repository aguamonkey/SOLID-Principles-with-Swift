import SwiftUI

/// Detail presentation delegates descriptive wording to the model.
struct AngelDetailView: View {
    let angel: AngelModel
    var body: some View {
        GuidePlate(name: angel.name, attribute: angel.power,
                   description: angel.describePower(), symbol: "sun.max")
    }
}
