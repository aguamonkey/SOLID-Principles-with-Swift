//
//  EntityRegistration.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

/// Creates the production registry used by app loaders.
public func makeProductionEntityRegistry() -> EntityRegistry {
    let registry = EntityRegistry()
    registry.register("Planet") { decoder in try Planet(from: decoder) }
    registry.register("Star")   { decoder in try Star(from: decoder)   }
    registry.register("Comet")  { decoder in try Comet(from: decoder)  }
    // Future entity types can register here without changing the factory.
    return registry
}
