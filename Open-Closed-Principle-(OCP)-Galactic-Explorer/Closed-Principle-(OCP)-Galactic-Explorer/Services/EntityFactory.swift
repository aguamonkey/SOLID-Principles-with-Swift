//
//  EntityFactory.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

/// A closure that decodes a SpaceEntity from a Decoder.
public typealias EntityDecoder = (Decoder) throws -> any SpaceEntity

/// Registry mapping type names to decoder closures.
public struct EntityFactory {
    private static var registry: [String: EntityDecoder] = [:]

    /// Register a decoder for a given entity type name.
    public static func register(_ typeName: String, decoder: @escaping EntityDecoder) {
        registry[typeName] = decoder
    }

    /// Dynamically decode a SpaceEntity based on its "type" field.
    public static func decode(from decoder: Decoder) throws -> any SpaceEntity {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        guard let entityDecoder = registry[typeName] else {
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown entity type: \(typeName)"
            )
        }
        return try entityDecoder(decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

struct AnySpaceEntity: Decodable {
    let entity: any SpaceEntity

    init(from decoder: Decoder) throws {
        self.entity = try EntityFactory.decode(from: decoder)
    }
}
