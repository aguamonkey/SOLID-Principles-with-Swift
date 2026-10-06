import SwiftUI

/// A catalog row renders a supplied value; it performs no data loading.
struct AngelView: View {
    let angel: AngelModel
    var body: some View {
        GuideEntry(name: angel.name, attribute: angel.power)
    }
}
