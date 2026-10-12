import Foundation

struct AtlasSchema: Hashable, Sendable {
    let type: String
    let version: Int
}

struct AtlasFact: Equatable, Sendable {
    let label: String
    let value: String
}

struct AtlasExtension: Sendable {
    let schema: AtlasSchema
    let decode: @Sendable (Data) throws -> [AtlasFact]
}

enum AtlasRegistrationError: Error, Equatable {
    case invalidSchema
    case duplicate(AtlasSchema)
}

/// Construct once at composition. There is no runtime registration API.
struct AtlasExtensionRegistry: Sendable {
    private let decoders: [AtlasSchema: @Sendable (Data) throws -> [AtlasFact]]

    init(_ extensions: [AtlasExtension]) throws {
        var entries: [AtlasSchema: @Sendable (Data) throws -> [AtlasFact]] = [:]
        for item in extensions {
            guard !item.schema.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  item.schema.version > 0 else { throw AtlasRegistrationError.invalidSchema }
            guard entries[item.schema] == nil else {
                throw AtlasRegistrationError.duplicate(item.schema)
            }
            entries[item.schema] = item.decode
        }
        decoders = entries
    }

    func decoder(for schema: AtlasSchema) -> (@Sendable (Data) throws -> [AtlasFact])? {
        decoders[schema]
    }
}
