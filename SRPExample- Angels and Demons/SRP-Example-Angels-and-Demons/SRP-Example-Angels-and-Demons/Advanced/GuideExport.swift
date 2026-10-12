import Foundation

/// Export consumers own field names and schema versions. No display prose enters this DTO.
struct GuideExportDocument: Codable, Equatable {
    struct Entry: Codable, Equatable {
        let id: UUID
        let kind: String
        let name: String
        let attribute: String
        let rank: String
    }
    let schemaVersion: Int
    let editionRevision: Int
    let entries: [Entry]
}

struct GuideExport {
    func encode(_ edition: GuideEdition) throws -> Data {
        let entries = edition.figures.sorted { $0.id.uuidString < $1.id.uuidString }.map {
            GuideExportDocument.Entry(id: $0.id, kind: $0.kind.rawValue,
                                      name: $0.name, attribute: $0.attribute, rank: $0.rank)
        }
        let document = GuideExportDocument(schemaVersion: 1, editionRevision: edition.revision, entries: entries)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(document)
    }
}
