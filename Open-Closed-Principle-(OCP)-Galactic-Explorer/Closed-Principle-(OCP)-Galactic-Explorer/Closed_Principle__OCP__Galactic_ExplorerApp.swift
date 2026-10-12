import SwiftUI

@main
struct OCPGalacticExplorerApp: App {
    private let entityRegistry = makeProductionEntityRegistry()

    var body: some Scene {
        WindowGroup {
            TabView {
                GalacticExplorerView(
                    viewModel: ExplorerViewModel(loader: JSONSpaceEntityLoader(registry: entityRegistry))
                ).tabItem { Label("Atlas", systemImage: "globe.europe.africa") }
                AtlasExtensionLab().tabItem { Label("Extension Lab", systemImage: "tray.and.arrow.down") }
            }
        }
    }
}
