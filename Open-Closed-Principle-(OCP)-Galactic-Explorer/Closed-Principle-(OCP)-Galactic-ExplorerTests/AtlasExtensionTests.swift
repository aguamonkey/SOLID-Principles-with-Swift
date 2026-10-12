import XCTest
@testable import Open_Closed_Principle__OCP__Galactic_Explorer

final class AtlasExtensionTests: XCTestCase {
    private func read(_ json: String, extensions: [AtlasExtension] = [AtlasLabComposition.planet]) throws -> [AtlasImportRow] {
        try AtlasImporter(registry: AtlasExtensionRegistry(extensions)).read(Data(json.utf8))
    }
    private func record(_ fields: String = "", id: String = "05000000-0000-0000-0000-000000000001", type: String = "Planet", version: Int = 1, payload: String = "{\"radiusKm\":1}") -> String {
        "{\"id\":\"\(id)\",\"type\":\"\(type)\",\"version\":\(version),\"name\":\"Sample\",\"payload\":\(payload)\(fields)}"
    }
    func testMixedBulletinPreservesOrderAndValidRecords() throws {
        let rows = try AtlasImporter(registry: AtlasLabComposition.registry(includeAsteroid: false)).read(AtlasLabComposition.bulletin)
        XCTAssertEqual(rows.map(\.id), [0, 1, 2, 3])
        guard case .accepted(name: "Earth", facts: _) = rows[0].outcome else { return XCTFail("Earth must survive") }
        guard case .unsupported(name: "Ceres", schema: _) = rows[1].outcome else { return XCTFail("Unknown type") }
        guard case .unsupported(name: _, schema: AtlasSchema(type: "Planet", version: 2)) = rows[2].outcome else { return XCTFail("Unknown version") }
        XCTAssertEqual(rows[3].outcome, .rejected(reason: "Invalid payload"))
    }
    func testAddingExtensionChangesOnlySupportedRecord() throws {
        let base = try AtlasImporter(registry: AtlasLabComposition.registry(includeAsteroid: false)).read(AtlasLabComposition.bulletin)
        let extended = try AtlasImporter(registry: AtlasLabComposition.registry(includeAsteroid: true)).read(AtlasLabComposition.bulletin)
        for i in [0, 2, 3] { XCTAssertEqual(base[i], extended[i]) }
        guard case .accepted(name: "Ceres", facts: _) = extended[1].outcome else { return XCTFail("Extension must decode") }
    }
    func testTestOnlyExtensionNeedsNoImporterChanges() throws {
        struct Payload: Decodable { let periodDays: Int }
        struct Record: Decodable { let payload: Payload }
        let comet = AtlasExtension(schema: AtlasSchema(type: "Comet", version: 1)) { data in
            let p = try JSONDecoder().decode(Record.self, from: data).payload
            return [AtlasFact(label: "PERIOD", value: "\(p.periodDays) days")]
        }
        let rows = try read("[\(record(type: "Comet", payload: "{\"periodDays\":75}"))]", extensions: [comet])
        XCTAssertEqual(rows[0].outcome, .accepted(name: "Sample", facts: [AtlasFact(label: "PERIOD", value: "75 days")]))
    }
    func testDuplicateRegistrationFailsInsteadOfLastWriterWinning() throws {
        XCTAssertThrowsError(try AtlasExtensionRegistry([AtlasLabComposition.planet, AtlasLabComposition.planet])) {
            XCTAssertEqual($0 as? AtlasRegistrationError, .duplicate(AtlasSchema(type: "Planet", version: 1)))
        }
    }
    func testDistinctVersionsCanCoexist() throws {
        let v2 = AtlasExtension(schema: AtlasSchema(type: "Planet", version: 2)) { _ in [AtlasFact(label: "VERSION", value: "2")] }
        let rows = try read("[\(record(version: 2))]", extensions: [AtlasLabComposition.planet, v2])
        XCTAssertEqual(rows[0].outcome, .accepted(name: "Sample", facts: [AtlasFact(label: "VERSION", value: "2")]))
    }
    func testInvalidRegistrationRejected() {
        for schema in [AtlasSchema(type: " ", version: 1), AtlasSchema(type: "Planet", version: 0)] {
            XCTAssertThrowsError(try AtlasExtensionRegistry([AtlasExtension(schema: schema, decode: { _ in [] })])) {
                XCTAssertEqual($0 as? AtlasRegistrationError, .invalidSchema)
            }
        }
    }
    func testUnknownPayloadIsNotDecoded() throws {
        let rows = try read("[\(record(type: "Future", payload: "null"))]")
        XCTAssertEqual(rows[0].outcome, .unsupported(name: "Sample", schema: AtlasSchema(type: "Future", version: 1)))
    }
    func testFutureVersionDoesNotFallBackToV1() throws {
        let rows = try read("[\(record(version: 2))]")
        XCTAssertEqual(rows[0].outcome, .unsupported(name: "Sample", schema: AtlasSchema(type: "Planet", version: 2)))
    }
    func testMalformedEnvelopeDoesNotPreventNextRecord() throws {
        let rows = try read("[{},\(record())]")
        XCTAssertEqual(rows[0].outcome, .rejected(reason: "Invalid envelope"))
        guard case .accepted = rows[1].outcome else { return XCTFail("Valid record lost") }
    }
    func testScalarRecordRejected() throws {
        let invalid = ["1", record(id: "invalid"), record(type: " "), record(version: 0),
                       record().replacingOccurrences(of: "Sample", with: " ")]
        for envelope in invalid {
            XCTAssertEqual(try read("[\(envelope)]")[0].outcome, .rejected(reason: "Invalid envelope"))
        }
    }
    func testMissingWrongTypedAndNegativePayloadRejected() throws {
        for payload in ["{}", "{\"radiusKm\":\"large\"}", "{\"radiusKm\":-1}"] {
            XCTAssertEqual(try read("[\(record(payload: payload))]")[0].outcome, .rejected(reason: "Invalid payload"))
        }
    }
    func testDuplicateDomainIDRejectedEvenAfterUnsupportedRecord() throws {
        let rows = try read("[\(record(type: "Future")),\(record())]")
        XCTAssertEqual(rows[1].outcome, .rejected(reason: "Duplicate record ID"))
    }
    func testInvalidPayloadStillClaimsID() throws {
        let rows = try read("[\(record(payload: "{}")),\(record())]")
        XCTAssertEqual(rows[1].outcome, .rejected(reason: "Duplicate record ID"))
    }
    func testAdditiveFieldsRemainCompatible() throws {
        XCTAssertEqual(try read("[\(record())]"), try read("[\(record(",\"newField\":true"))]"))
    }
    func testBrokenExtensionOutputContained() throws {
        for facts in [[], [AtlasFact(label: " ", value: "value")], [AtlasFact(label: "label", value: "")]] {
            let broken = AtlasExtension(schema: AtlasSchema(type: "Planet", version: 1)) { _ in facts }
            XCTAssertEqual(try read("[\(record())]", extensions: [broken])[0].outcome, .rejected(reason: "Invalid extension output"))
        }
    }
    func testEmptyDocumentIsSuccessfulEmptyReport() throws {
        XCTAssertEqual(try read("[]"), [])
    }
    func testMalformedOrNonArrayDocumentFailsAsAWhole() {
        for json in ["[", "{}", "null"] { XCTAssertThrowsError(try read(json)) }
    }
    func testImmutableRegistryCanServeConcurrentImports() async throws {
        let importer = try AtlasImporter(registry: AtlasLabComposition.registry(includeAsteroid: true))
        let expected = try importer.read(AtlasLabComposition.bulletin)
        let results = try await withThrowingTaskGroup(of: [AtlasImportRow].self) { group in
            for _ in 0..<10 { group.addTask { try importer.read(AtlasLabComposition.bulletin) } }
            var results: [[AtlasImportRow]] = []
            for try await report in group { results.append(report) }
            return results
        }
        XCTAssertEqual(results.count, 10)
        for report in results { XCTAssertEqual(report, expected) }
    }
}
