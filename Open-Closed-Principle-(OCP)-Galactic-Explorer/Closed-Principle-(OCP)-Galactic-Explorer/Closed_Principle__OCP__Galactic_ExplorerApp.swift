//
//  Closed_Principle__OCP__Galactic_ExplorerApp.swift
//  Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//
//
//  OCPGalacticExplorerApp.swift
//  OCPGalacticExplorer
//
//  Created by Gobias LTD on 2025-05-17.
//

import SwiftUI

@main
struct OCPGalacticExplorerApp: App {
    private let entityRegistry = makeProductionEntityRegistry()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Use only the bundle JSON loader:
                let jsonLoader = JSONSpaceEntityLoader(registry: entityRegistry) // defaults to “entities.json” in app bundle

                // If you still want API fallback, you can swap in the composite:
                // let loader = CompositeSpaceEntityLoader(loaders: [
                //     JSONSpaceEntityLoader(registry: entityRegistry),
                //     APISpaceEntityLoader(endpoint: URL(string: "https://api.example.com/entities")!, registry: entityRegistry)
                // ])

                GalacticExplorerView(
                    viewModel: ExplorerViewModel(loader: jsonLoader)
                )
            }
        }
    }
}
