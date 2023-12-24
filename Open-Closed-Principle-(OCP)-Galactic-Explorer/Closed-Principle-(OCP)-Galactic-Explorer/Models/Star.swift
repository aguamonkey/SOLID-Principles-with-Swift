//
//  Star.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Models/Star.swift

// Star is another subclass of SpaceEntity, demonstrating the extendibility of the base class.

class Star: SpaceEntity {
    var type: String

    init(name: String, description: String, type: String) {
        self.type = type
        super.init(name: name, description: description)
    }
    
    // Required initializer for decoding
    required init(from decoder: Decoder) throws {
        // Create a container using the inherited coding keys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the 'type' property specific to Star
        self.type = try container.decode(String.self, forKey: .type)

        // Call the superclass initializer to decode properties defined in SpaceEntity
        try super.init(from: decoder)
    }
    
    // Coding keys specific to Star, in addition to those in SpaceEntity
    private enum CodingKeys: String, CodingKey {
        case type
    }

    // Star-specific properties and methods can be implemented here.
}

extension Star: Luminous {
    func luminosity() -> Double {
        // Mock implementation
        return 1.0 // Assuming Sun-like star for simplicity
    }
}

