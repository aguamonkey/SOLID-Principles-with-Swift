//
//  SRP_Example_Angels_and_DemonsApp.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 12/12/2023.
//

import SwiftUI

@main
struct SRP_Example_Angels_and_DemonsApp: App {
    let dataService: DataServiceProtocol = DataService()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView(dataService: dataService)
                    .tabItem { Label("Field Guide", systemImage: "book") }
                GuideOwnershipLab()
                    .tabItem { Label("Edition Lab", systemImage: "doc.on.doc") }
            }
        }
    }
}
