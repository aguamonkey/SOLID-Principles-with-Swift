import Foundation

/// Each extension owns its payload schema and validation, not the import loop.
enum AtlasLabComposition {
    static let planet = AtlasExtension(schema: AtlasSchema(type: "Planet", version: 1)) { data in
        struct Record: Decodable {
            struct Payload: Decodable { let radiusKm: Double }
            let payload: Payload
        }
        let radius = try JSONDecoder().decode(Record.self, from: data).payload.radiusKm
        guard radius.isFinite, radius > 0 else { throw PayloadError.invalid }
        return [AtlasFact(label: "RADIUS", value: "\(radius.formatted()) km")]
    }

    static let asteroid = AtlasExtension(schema: AtlasSchema(type: "Asteroid", version: 1)) { data in
        struct Record: Decodable {
            struct Payload: Decodable { let diameterKm: Double }
            let payload: Payload
        }
        let diameter = try JSONDecoder().decode(Record.self, from: data).payload.diameterKm
        guard diameter.isFinite, diameter > 0 else { throw PayloadError.invalid }
        return [AtlasFact(label: "DIAMETER", value: "\(diameter.formatted()) km")]
    }

    enum PayloadError: Error { case invalid }

    static func registry(includeAsteroid: Bool) throws -> AtlasExtensionRegistry {
        try AtlasExtensionRegistry(includeAsteroid ? [planet, asteroid] : [planet])
    }

    // Offline fixture: a future version must not be guessed to mean version 1.
    static let bulletin = Data("""
    [
      {"id":"05000000-0000-0000-0000-000000000001","type":"Planet","version":1,"name":"Earth","payload":{"radiusKm":6371}},
      {"id":"05000000-0000-0000-0000-000000000002","type":"Asteroid","version":1,"name":"Ceres","payload":{"diameterKm":939.4}},
      {"id":"05000000-0000-0000-0000-000000000003","type":"Planet","version":2,"name":"Future observation","payload":{"radiusMetres":2000}},
      {"id":"05000000-0000-0000-0000-000000000004","type":"Planet","version":1,"name":"Damaged observation","payload":{"radiusKm":-1}}
    ]
    """.utf8)
}
