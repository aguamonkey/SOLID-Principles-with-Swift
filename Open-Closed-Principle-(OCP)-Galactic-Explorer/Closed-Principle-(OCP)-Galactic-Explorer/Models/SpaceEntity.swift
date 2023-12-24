//
//  SpaceEntity.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Models/SpaceEntity.swift

// SpaceEntity is the base class for all space entities. It defines common properties and methods.
// Aligning with OCP, it's designed to be extended (for new space entities) without needing modification.
class SpaceEntity: Codable {
    var name: String
    var description: String

    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    // Common functionality that all space entities will share can be defined here.
}
