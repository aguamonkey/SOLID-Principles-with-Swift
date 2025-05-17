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
    init() {
        // Register all the SpaceEntity types for decoding
        registerEntityTypes()
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                // Use only the bundle JSON loader:
                let jsonLoader = JSONSpaceEntityLoader() // defaults to “entities.json” in app bundle

                // If you still want API fallback, you can swap in the composite:
                // let loader = CompositeSpaceEntityLoader(loaders: [
                //     JSONSpaceEntityLoader(),
                //     APISpaceEntityLoader(endpoint: URL(string: "https://api.example.com/entities")!)
                // ])

                GalacticExplorerView(
                    viewModel: ExplorerViewModel(loader: jsonLoader)
                )
            }
        }
    }
}
