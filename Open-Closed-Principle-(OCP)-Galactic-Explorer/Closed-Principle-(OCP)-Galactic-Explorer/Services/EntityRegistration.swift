//
//  EntityRegistration.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

// File: Services/EntityRegistration.swift

import Foundation

/// Call once at app startup to register all entity decoders.
public func registerEntityTypes() {
    EntityFactory.register("Planet") { decoder in try Planet(from: decoder) }
    EntityFactory.register("Star")   { decoder in try Star(from: decoder)   }
    EntityFactory.register("Comet")  { decoder in try Comet(from: decoder)  }
    // → In future, register("Asteroid") etc. without touching core code
}
