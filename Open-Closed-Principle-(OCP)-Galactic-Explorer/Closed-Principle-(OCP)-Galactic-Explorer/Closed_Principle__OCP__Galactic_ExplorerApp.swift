import SwiftUI

@main
struct OCPGalacticExplorerApp: App {
    private let entityRegistry = makeProductionEntityRegistry()

    var body: some Scene {
        WindowGroup {
            GalacticExplorerView(
                viewModel: ExplorerViewModel(
                    loader: JSONSpaceEntityLoader(registry: entityRegistry)
                )
            )
        }
    }
}
