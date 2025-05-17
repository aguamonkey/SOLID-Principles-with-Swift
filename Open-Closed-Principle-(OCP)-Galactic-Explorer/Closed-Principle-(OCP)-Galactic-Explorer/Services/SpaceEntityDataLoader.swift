//
//  SpaceEntityDataLoader.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

/// Protocol defining a one-off data source for SpaceEntity instances.
/// OCP: New data sources can be added via new conforming types without modifying existing code.
public protocol SpaceEntityDataLoader {
    func loadEntities() async throws -> [any SpaceEntity]
}

