//
//  CompositeLoader.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

/// Merges multiple SpaceEntityDataLoaders into one composite loader.
public struct CompositeSpaceEntityLoader: SpaceEntityDataLoader {
    private let loaders: [SpaceEntityDataLoader]

    public init(loaders: [SpaceEntityDataLoader]) {
        self.loaders = loaders
    }

    public func loadEntities() async throws -> [any SpaceEntity] {
        var all: [any SpaceEntity] = []
        for loader in loaders {
            all += try await loader.loadEntities()
        }
        return all
    }
}
