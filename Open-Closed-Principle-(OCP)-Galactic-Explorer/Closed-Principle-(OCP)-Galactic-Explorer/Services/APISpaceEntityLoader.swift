//
//  APISpaceEntityLoader.swift
//  OCPGalacticExplorer
//
//  Created by Gobias LTD on 2025-05-17.
//

import Foundation

/// Fetches SpaceEntity data from a remote API endpoint.
/// Uses the same AnySpaceEntity wrapper to pick the right subtype at runtime.
public struct APISpaceEntityLoader: SpaceEntityDataLoader {
    public let endpoint: URL

    public init(endpoint: URL) {
        self.endpoint = endpoint
    }

    public func loadEntities() async throws -> [any SpaceEntity] {
        print("[APILoader] Fetching from API:", endpoint.absoluteString)
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        let decoder = JSONDecoder()
        let wrappers = try decoder.decode([AnySpaceEntity].self, from: data)
        let extracted = wrappers.map { $0.entity }
        print("[APILoader] Received \(extracted.count) entities from API")
        return extracted
    }

}
