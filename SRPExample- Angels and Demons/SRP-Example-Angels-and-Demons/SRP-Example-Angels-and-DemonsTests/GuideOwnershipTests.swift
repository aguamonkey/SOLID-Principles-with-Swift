import XCTest
@testable import SRP_Example_Angels_and_Demons

@MainActor
final class GuideOwnershipTests: XCTestCase {
    private func edition(_ revision: Int = 1) throws -> GuideEdition {
        try SampleEditionSource.edition(revision: revision)
    }
    func testNonPositiveRevisionRejected() {
        for revision in [0, -1] {
            XCTAssertThrowsError(try GuideEdition(revision: revision, figures: [])) {
                XCTAssertEqual($0 as? GuideEditionError, .invalidRevision)
            }
        }
    }
    func testDuplicateDomainIdentityRejectedEvenWithDifferentNames() throws {
        let figure = try edition().figures[0]
        let duplicate = GuideFigure(id: figure.id, kind: .demon, name: "Other", attribute: "Other", rank: "Other")
        XCTAssertThrowsError(try GuideEdition(revision: 1, figures: [figure, duplicate])) {
            XCTAssertEqual($0 as? GuideEditionError, .duplicateIdentity)
        }
        let sameName = GuideFigure(id: UUID(), kind: figure.kind, name: figure.name,
                                   attribute: figure.attribute, rank: figure.rank)
        let valid = try GuideEdition(revision: 1, figures: [figure, sameName])
        XCTAssertEqual(GuideEditorial(voice: .narrative).readings(from: valid).count, 2)
    }
    func testIncompleteFactsRejectedBeforeProjection() {
        let id = UUID()
        for values in [(" ", "Power", "Rank"), ("Name", "", "Rank"), ("Name", "Power", "\n")] {
            let figure = GuideFigure(id: id, kind: .angel, name: values.0, attribute: values.1, rank: values.2)
            XCTAssertThrowsError(try GuideEdition(revision: 1, figures: [figure])) {
                XCTAssertEqual($0 as? GuideEditionError, .incompleteFigure)
            }
        }
    }
    func testEmptyEditionIsValidData() throws {
        XCTAssertEqual(try GuideEdition(revision: 1, figures: []).figures, [])
    }
    func testEditorialVoiceChangesProseWithoutChangingExportOrFacts() throws {
        let snapshot = try edition()
        let before = try GuideExport().encode(snapshot)
        let narrative = GuideEditorial(voice: .narrative).readings(from: snapshot)
        let notes = GuideEditorial(voice: .indexNotes).readings(from: snapshot)
        XCTAssertNotEqual(narrative[0].prose, notes[0].prose)
        XCTAssertEqual(narrative.map(\.id), notes.map(\.id))
        XCTAssertEqual(narrative.map(\.name), notes.map(\.name))
        XCTAssertEqual(try GuideExport().encode(snapshot), before)
        XCTAssertEqual(snapshot, try edition())
    }
    func testEditorialProjectionPreservesSourceOrderAndBothKinds() throws {
        let snapshot = try edition()
        let rows = GuideEditorial(voice: .narrative).readings(from: snapshot)
        XCTAssertEqual(rows.map(\.id), snapshot.figures.map(\.id))
        XCTAssertEqual(rows.map(\.name), ["Michael", "Lucifer"])
        XCTAssertTrue(rows[0].annotation.contains("ANGEL"))
        XCTAssertTrue(rows[1].annotation.contains("DEMON"))
        XCTAssertTrue(rows[0].prose.contains("Protection"))
        XCTAssertTrue(rows[1].prose.contains("Princes"))
    }
    func testExportHasVersionedMachineFieldsWithoutDisplayProse() throws {
        let snapshot = try edition()
        let data = try GuideExport().encode(snapshot)
        let document = try JSONDecoder().decode(GuideExportDocument.self, from: data)
        XCTAssertEqual(document.schemaVersion, 1)
        XCTAssertEqual(document.editionRevision, snapshot.revision)
        XCTAssertEqual(document.entries.map(\.kind), ["angel", "demon"])
        XCTAssertEqual(document.entries.map(\.id), snapshot.figures.map(\.id))
        XCTAssertEqual(document.entries.map(\.attribute), ["Protection", "Pride"])
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(Set(object.keys), ["schemaVersion", "editionRevision", "entries"])
        let entries = try XCTUnwrap(object["entries"] as? [[String: Any]])
        XCTAssertEqual(Set(entries[0].keys), ["id", "kind", "name", "attribute", "rank"])
    }
    func testExportOrderingIndependentOfSourceOrdering() throws {
        let snapshot = try edition()
        let reordered = try GuideEdition(revision: snapshot.revision, figures: snapshot.figures.reversed())
        XCTAssertEqual(try GuideExport().encode(snapshot), try GuideExport().encode(reordered))
    }
    func testExportEscapesUnicodeQuotesAndNewlines() throws {
        let figure = GuideFigure(id: UUID(), kind: .angel, name: "Étoile \"A\"", attribute: "Line\nTwo", rank: "Order")
        let data = try GuideExport().encode(GuideEdition(revision: 1, figures: [figure]))
        let decoded = try JSONDecoder().decode(GuideExportDocument.self, from: data)
        XCTAssertEqual(decoded.entries[0].name, figure.name)
        XCTAssertEqual(decoded.entries[0].attribute, figure.attribute)
    }
    func testNewEditionUpdatesBothConsumersFromSameFacts() throws {
        let old = try edition(1)
        let new = try edition(2)
        XCTAssertNotEqual(GuideEditorial(voice: .narrative).readings(from: old), GuideEditorial(voice: .narrative).readings(from: new))
        let doc = try JSONDecoder().decode(GuideExportDocument.self, from: GuideExport().encode(new))
        XCTAssertEqual(doc.editionRevision, 2)
        XCTAssertEqual(doc.entries[0].attribute, "Guardianship")
    }
    func testSuccessfulLoadPublishesValidatedEdition() async throws {
        let expected = try edition()
        let model = GuideEditionModel(source: FixedEditionSource(result: .success(expected)))
        let work = model.refresh()
        XCTAssertTrue(model.isLoading)
        await work.value
        XCTAssertEqual(model.edition, expected)
        XCTAssertFalse(model.isLoading)
        XCTAssertNil(model.warning)
    }
    func testFirstFailureIsNotSuccessfulEmptyEdition() async {
        let model = GuideEditionModel(source: FixedEditionSource(result: .failure(TestError.offline)))
        await model.refresh().value
        XCTAssertNil(model.edition)
        XCTAssertEqual(model.warning, "No edition could be loaded. Try refreshing.")
        XCTAssertFalse(model.isLoading)
    }
    func testFailedRefreshRetainsSameEditionForBothConsumers() async throws {
        let gate = ControlledEditionSource()
        let model = GuideEditionModel(source: gate)
        let first = model.refresh(); await gate.waitForRequests(1)
        await gate.complete(0, result: .success(try edition()))
        await first.value
        let before = try XCTUnwrap(model.edition)
        let export = try GuideExport().encode(before)
        let readings = GuideEditorial(voice: .narrative).readings(from: before)
        let failed = model.refresh(); await gate.waitForRequests(2)
        await gate.complete(1, result: .failure(TestError.offline)); await failed.value
        let retained = try XCTUnwrap(model.edition)
        XCTAssertEqual(retained, before)
        XCTAssertEqual(try GuideExport().encode(retained), export)
        XCTAssertEqual(GuideEditorial(voice: .narrative).readings(from: retained), readings)
        XCTAssertNotNil(model.warning)
    }
    func testInvalidIncomingEditionCannotReplaceValidSnapshot() async throws {
        let gate = ControlledEditionSource(); let model = GuideEditionModel(source: gate)
        let first = model.refresh(); await gate.waitForRequests(1)
        await gate.complete(0, result: .success(try edition())); await first.value
        let next = model.refresh(); await gate.waitForRequests(2)
        await gate.complete(1, result: .failure(GuideEditionError.duplicateIdentity)); await next.value
        XCTAssertEqual(model.edition, try edition())
        XCTAssertNotNil(model.warning)
    }
    func testLoadedEmptyEditionProducesSuccessfulEmptyConsumers() async throws {
        let empty = try GuideEdition(revision: 1, figures: [])
        let model = GuideEditionModel(source: FixedEditionSource(result: .success(empty)))
        await model.refresh().value
        let loaded = try XCTUnwrap(model.edition)
        XCTAssertEqual(GuideEditorial(voice: .narrative).readings(from: loaded), [])
        let document = try JSONDecoder().decode(GuideExportDocument.self, from: GuideExport().encode(loaded))
        XCTAssertEqual(document.entries, [])
        XCTAssertNil(model.warning)
    }
    func testOlderSuccessCannotReplaceNewerEdition() async throws {
        let gate = ControlledEditionSource(); let model = GuideEditionModel(source: gate)
        let older = model.refresh(); await gate.waitForRequests(1)
        let newer = model.refresh(); await gate.waitForRequests(2)
        await gate.complete(1, result: .success(try edition(2))); await newer.value
        await gate.complete(0, result: .success(try edition(1))); await older.value
        XCTAssertEqual(model.edition?.revision, 2)
        XCTAssertNil(model.warning)
    }
    func testOlderFailureCannotPublishWarningAfterNewerSuccess() async throws {
        let gate = ControlledEditionSource(); let model = GuideEditionModel(source: gate)
        let older = model.refresh(); await gate.waitForRequests(1)
        let newer = model.refresh(); await gate.waitForRequests(2)
        await gate.complete(1, result: .success(try edition(2))); await newer.value
        await gate.complete(0, result: .failure(TestError.offline)); await older.value
        XCTAssertEqual(model.edition?.revision, 2)
        XCTAssertNil(model.warning)
        XCTAssertFalse(model.isLoading)
    }
    func testCancelPreventsLatePublicationFromUncooperativeSource() async throws {
        let gate = ControlledEditionSource(); let model = GuideEditionModel(source: gate)
        let work = model.refresh(); await gate.waitForRequests(1)
        model.cancel()
        XCTAssertFalse(model.isLoading)
        await gate.complete(0, result: .success(try edition())); await work.value
        XCTAssertNil(model.edition)
        XCTAssertNil(model.warning)
    }
    func testSourceCancellationIsNotReportedAsFailure() async {
        let model = GuideEditionModel(source: FixedEditionSource(result: .failure(CancellationError())))
        await model.refresh().value
        XCTAssertNil(model.warning)
        XCTAssertFalse(model.isLoading)
    }
    func testConsumerSwitchingAndWordingNeedNoAdditionalReads() async throws {
        let source = CountingEditionSource(edition: try edition())
        let model = GuideEditionModel(source: source)
        await model.refresh().value
        let snapshot = try XCTUnwrap(model.edition)
        for _ in 0..<5 {
            _ = GuideEditorial(voice: .narrative).readings(from: snapshot)
            _ = GuideEditorial(voice: .indexNotes).readings(from: snapshot)
            _ = try GuideExport().encode(snapshot)
        }
        let reads = await source.count
        XCTAssertEqual(reads, 1)
    }
}

private enum TestError: Error { case offline }
private struct FixedEditionSource: GuideEditionSource {
    let result: Result<GuideEdition, Error>
    func readEdition() async throws -> GuideEdition { try result.get() }
}
private actor CountingEditionSource: GuideEditionSource {
    let edition: GuideEdition
    private(set) var count = 0
    init(edition: GuideEdition) { self.edition = edition }
    func readEdition() async throws -> GuideEdition { count += 1; return edition }
}

/// Intentionally ignores cancellation; tests control completion order without sleeps.
private actor ControlledEditionSource: GuideEditionSource {
    private var pending: [CheckedContinuation<GuideEdition, Error>?] = []
    private var waiters: [(Int, CheckedContinuation<Void, Never>)] = []
    func readEdition() async throws -> GuideEdition {
        try await withCheckedThrowingContinuation { continuation in
            pending.append(continuation)
            let ready = waiters.filter { $0.0 <= pending.count }
            waiters.removeAll { $0.0 <= pending.count }
            ready.forEach { $0.1.resume() }
        }
    }
    func waitForRequests(_ count: Int) async {
        if pending.count >= count { return }
        await withCheckedContinuation { waiters.append((count, $0)) }
    }
    func complete(_ index: Int, result: Result<GuideEdition, Error>) {
        let continuation = pending[index]
        pending[index] = nil
        continuation?.resume(with: result)
    }
}
