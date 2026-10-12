import Foundation

struct AtlasEnvelope: Decodable, Sendable {
    let id: UUID
    let type: String
    let version: Int
    let name: String
    var schema: AtlasSchema { AtlasSchema(type: type, version: version) }
}

enum AtlasImportOutcome: Equatable, Sendable {
    case accepted(name: String, facts: [AtlasFact])
    case unsupported(name: String, schema: AtlasSchema)
    case rejected(reason: String)
}

struct AtlasImportRow: Identifiable, Equatable, Sendable {
    // Index is report identity only; envelope UUID is the domain identity.
    let id: Int
    let outcome: AtlasImportOutcome
}

enum AtlasDocumentError: Error { case expectedArray }

/// Per-record recovery is deliberate. Invalid top-level JSON still fails the document.
struct AtlasImporter: Sendable {
    let registry: AtlasExtensionRegistry

    func read(_ data: Data) throws -> [AtlasImportRow] {
        guard let records = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            throw AtlasDocumentError.expectedArray
        }
        var seen = Set<UUID>()
        return records.enumerated().map { index, record in
            let outcome: AtlasImportOutcome
            do {
                guard JSONSerialization.isValidJSONObject(record) else {
                    return AtlasImportRow(id: index, outcome: .rejected(reason: "Invalid envelope"))
                }
                let bytes = try JSONSerialization.data(withJSONObject: record)
                let envelope = try JSONDecoder().decode(AtlasEnvelope.self, from: bytes)
                guard !envelope.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !envelope.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      envelope.version > 0 else {
                    return AtlasImportRow(id: index, outcome: .rejected(reason: "Invalid envelope"))
                }
                // First valid envelope claims its ID, even if its payload is unsupported/invalid.
                guard seen.insert(envelope.id).inserted else {
                    return AtlasImportRow(id: index, outcome: .rejected(reason: "Duplicate record ID"))
                }
                guard let decode = registry.decoder(for: envelope.schema) else {
                    return AtlasImportRow(id: index, outcome: .unsupported(name: envelope.name, schema: envelope.schema))
                }
                do {
                    let facts = try decode(bytes)
                    guard !facts.isEmpty, facts.allSatisfy({
                        !$0.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                        !$0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }) else {
                        return AtlasImportRow(id: index, outcome: .rejected(reason: "Invalid extension output"))
                    }
                    outcome = .accepted(name: envelope.name, facts: facts)
                } catch {
                    outcome = .rejected(reason: "Invalid payload")
                }
            } catch {
                outcome = .rejected(reason: "Invalid envelope")
            }
            return AtlasImportRow(id: index, outcome: outcome)
        }
    }
}
