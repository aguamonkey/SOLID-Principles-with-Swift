//
//  SpaceEntityLoader.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI

// Services/SpaceEntityLoader.swift

// SpaceEntityLoader is responsible for loading space entity data.
// It adheres to OCP by allowing new data types to be added without changing existing code.
class SpaceEntityLoader {
    // This method is a mock implementation that returns a hardcoded list of space entities.
    // In a real application, this could fetch data from an external source.
    func loadEntities() -> [SpaceEntity] {
        // Mock data
        let planet = Planet(name: "Earth", description: "A planet with diverse ecosystems", numberOfMoons: 1)
        let star = Star(name: "Sun", description: "A medium-sized star", type: "G-Type")
        let comet = Comet(name: "Halley", description: "A comet visible from Earth every 76 years", tailLength: 24.0)

        // Return an array of various space entities
        return [planet, star, comet]
    }

    // Categorizes entities by their type without modifying the existing loading functionality.
    // This method can handle any new SpaceEntity types added in the future.
    func categorizeEntities(byType entities: [SpaceEntity]) -> [String: [SpaceEntity]] {
        var categories = [String: [SpaceEntity]]()
        for entity in entities {
            let type = String(describing: type(of: entity))
            categories[type, default: []].append(entity)
        }
        return categories
    }
    
    func loadEntitiesFromJSON() -> [SpaceEntity] {
            // Assuming a JSON format for space entities
            // This is a simplified example; in a real app, you would handle errors and more complex data structures.

            let jsonData = """
            [
                {"type": "Planet", "name": "Earth", "description": "A planet with diverse ecosystems", "numberOfMoons": 1},
                {"type": "Star", "name": "Sun", "description": "A medium-sized star", "type": "G-Type"}
            ]
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            do {
                let entities = try decoder.decode([SpaceEntity].self, from: jsonData)
                return entities
            } catch {
                print("Error decoding data: \(error)")
                return []
            }
    }
}
