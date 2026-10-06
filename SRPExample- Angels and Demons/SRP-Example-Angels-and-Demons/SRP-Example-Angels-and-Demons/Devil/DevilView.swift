import SwiftUI

/// A catalog row renders a supplied value; it performs no data loading.
struct DemonView: View {
    let demon: DemonModel
    var body: some View {
        GuideEntry(name: demon.name, attribute: demon.ability)
    }
}
