//
//  GalacticExplorerView.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Views/GalacticExplorerView.swift

import SwiftUI

// GalacticExplorerView is a SwiftUI view for displaying SpaceEntity objects.
// It's designed to work with any subclass of SpaceEntity, showcasing OCP by being open to extension.
struct GalacticExplorerView: View {
    var spaceEntities: [SpaceEntity]

    var body: some View {
        List(spaceEntities, id: \.name) { entity in
            VStack(alignment: .leading) {
                Text("Name: \(entity.name)")
                Text("Description: \(entity.description)")
                // This view can display any SpaceEntity without needing to know the specific subclass,
                // demonstrating how new types of space entities can be added without modifying this view.
                // Display additional details based on entity type
                if let comet = entity as? Comet {
                    Text("Comet Tail Length: \(comet.tailLength) km")
                }
                // More type checks can be added here for other subclasses.
            }
        }
    }
}
