//
//  AngelListView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

import SwiftUI


// AngelListView is responsible for displaying a list of angels.
// It adheres to SRP by handling only the presentation of AngelView instances within a list.
// AngelListView handles asynchronous loading of angel data and builds the hierarchy.
struct AngelListView: View {
    let dataService: DataServiceProtocol
    @State private var hierarchy: AngelHierarchy?
    
    var body: some View {
        Group {
            if let hierarchy = hierarchy {
                List(hierarchy.angels, id: \.name) { angel in
                    NavigationLink(destination: AngelDetailView(angel: angel)) {
                        AngelView(angel: angel)
                    }
                }
                .navigationBarTitle("Angels - \(hierarchy.rank)")
            } else {
                ProgressView("Loading Angels...")
            }
        }
        .task {
            do {
                let angels = try await dataService.getAllAngels()
                hierarchy = AngelHierarchy(rank: "Archangel", angels: angels)
            } catch {
                print("Error fetching angels: \(error)")
            }
        }
    }
}
