//
//  DevilListView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

// DemonListView is responsible for displaying a list of demons.
// It maintains SRP by focusing only on the presentation of DemonView instances.
// DemonListView handles asynchronous loading of demon data and builds the hierarchy.
struct DemonListView: View {
    let dataService: DataServiceProtocol
    @State private var hierarchy: DemonHierarchy?
    
    var body: some View {
        Group {
            if let hierarchy = hierarchy {
                List(hierarchy.demons, id: \.name) { demon in
                    NavigationLink(destination: DemonDetailView(demon: demon)) {
                        DemonView(demon: demon)
                    }
                }
                .navigationBarTitle("Demons - \(hierarchy.rank)")
            } else {
                ProgressView("Loading Demons...")
            }
        }
        .task {
            do {
                let demons = try await dataService.getAllDemons()
                hierarchy = DemonHierarchy(rank: "Greater Demon", demons: demons)
            } catch {
                print("Error fetching demons: \(error)")
            }
        }
    }
}
