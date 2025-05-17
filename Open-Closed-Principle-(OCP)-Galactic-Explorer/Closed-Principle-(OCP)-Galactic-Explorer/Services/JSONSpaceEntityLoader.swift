//
//  JSONSpaceEntityLoader.swift
//  OCPGalacticExplorer
//
//  Created by Gobias LTD on 2025-05-17.
//

import Foundation

/// Loads SpaceEntity data from a local JSON file.
/// Decodes into [`AnySpaceEntity`](EntityFactory.swift) wrappers, then extracts the real entities.
//
//  JSONSpaceEntityLoader.swift
//  OCPGalacticExplorer
//

import Foundation

/// Loads a JSON file from the app bundle by resource name,
/// decodes it via `AnySpaceEntity`, and returns the real entities.
public struct JSONSpaceEntityLoader: SpaceEntityDataLoader {
    private let resourceName: String
    private let resourceExtension: String

    /// - Parameters:
    ///   - resourceName: the base filename in your bundle (no “.json” suffix)
    ///   - resourceExtension: the file extension (usually “json”)
    public init(resourceName: String = "entities", resourceExtension: String = "json") {
        self.resourceName = resourceName
        self.resourceExtension = resourceExtension
    }

    public func loadEntities() async throws -> [any SpaceEntity] {
        // 1. Locate the file in the bundle
        guard let url = Bundle.main.url(
                forResource: resourceName,
                withExtension: resourceExtension)
        else {
            throw NSError(
                domain: "JSONLoader",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey:
                    "Bundle resource “\(resourceName).\(resourceExtension)” not found"]
            )
        }
        print("[JSONLoader] Found bundle URL:", url)

        // 2. Load Data
        let data = try Data(contentsOf: url)

        // 3. Decode via our AnySpaceEntity wrapper
        let wrappers = try JSONDecoder().decode([AnySpaceEntity].self, from: data)
        let entities = wrappers.map { $0.entity }
        print("[JSONLoader] Decoded \(entities.count) entities:", entities.map { $0.name })

        return entities
    }
}
