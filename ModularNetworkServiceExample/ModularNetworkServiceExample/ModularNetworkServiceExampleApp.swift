//
//  ModularNetworkServiceExampleApp.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import SwiftUI

@main
struct ModularNetworkServiceExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NetworkLabView()
                    .tabItem { Label("Patchboard", systemImage: "cable.connector") }
                RefreshLabView()
                    .tabItem { Label("Refresh Lab", systemImage: "arrow.clockwise") }
            }
            .tint(PatchboardStyle.accent)
        }
    }
}
