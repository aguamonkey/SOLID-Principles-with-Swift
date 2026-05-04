//
//  EntityRegistry.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation

/// A closure that decodes a SpaceEntity from a Decoder.
public typealias EntityDecoder = @Sendable (Decoder) throws -> any SpaceEntity

/// Instance-owned registry mapping type names to decoder closures.
public final class EntityRegistry: @unchecked Sendable {
    private var decoders: [String: EntityDecoder] = [:]

    public init() {}

    /// Register a decoder for a given entity type name.
    public func register(_ typeName: String, decoder: @escaping EntityDecoder) {
        decoders[typeName] = decoder
    }

    /// Dynamically decode a SpaceEntity based on its "type" field.
    public func decode(from decoder: Decoder) throws -> any SpaceEntity {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        guard let entityDecoder = decoders[typeName] else {
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

extension CodingUserInfoKey {
    static let entityRegistry = CodingUserInfoKey(rawValue: "entityRegistry")!
}

struct AnySpaceEntity: Decodable {
    let entity: any SpaceEntity

    init(from decoder: Decoder) throws {
        guard let registry = decoder.userInfo[.entityRegistry] as? EntityRegistry else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Missing EntityRegistry in decoder.userInfo"
            )
            throw DecodingError.dataCorrupted(context)
        }

        self.entity = try registry.decode(from: decoder)
    }
}
