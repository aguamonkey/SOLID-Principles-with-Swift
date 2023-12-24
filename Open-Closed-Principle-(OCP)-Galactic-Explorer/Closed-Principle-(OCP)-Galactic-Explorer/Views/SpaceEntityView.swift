//
//  SpaceEntityView.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI
// Generic SwiftUI components

// Views/SpaceEntityView.swift

struct SpaceEntityView<Entity: SpaceEntity>: View {
    var entity: Entity

    var body: some View {
        VStack {
            Text("Name: \(entity.name)")
            Text("Description: \(entity.description)")
            // Handling specific types
            if let planet = entity as? Planet {
                Text("Number of Moons: \(planet.numberOfMoons)")
            } else if let star = entity as? Star {
                Text("Star Type: \(star.type)")
            }
            // Additional entity type handling can be added here.
        }
    }
}

