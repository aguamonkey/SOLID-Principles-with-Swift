//
//  Comet.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Models/Comet.swift

// Comet is a new subclass of SpaceEntity, added without modifying any existing classes.
class Comet: SpaceEntity {
    var tailLength: Double

    init(name: String, description: String, tailLength: Double) {
        self.tailLength = tailLength
        super.init(name: name, description: description)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // Comet-specific properties and methods can be added here.
}
