//
//  Planet.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Models/Planet.swift

// Planet is a subclass of SpaceEntity. It extends SpaceEntity without modifying it, adhering to OCP.
class Planet: SpaceEntity {
    var numberOfMoons: Int

    init(name: String, description: String, numberOfMoons: Int) {
        self.numberOfMoons = numberOfMoons
        super.init(name: name, description: description)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // Additional properties and methods specific to planets can be added here.
}

extension Planet: Orbitable {
    func orbitPath() -> String {
        // Mock implementation
        return "\(name) orbits its star in a nearly circular path."
    }
}
