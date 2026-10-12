import XCTest
@testable import EcoShop_Backend_ISP

@MainActor
final class OrderCapabilityTests: XCTestCase {
    private func draft(id: UUID = UUID(), reference: String = "EC-01", total: Int = 1250) -> OrderDraft {
        OrderDraft(id: id, reference: reference, totalPence: total)
    }
    private func receipt(_ draft: OrderDraft) -> OrderReceipt {
        OrderReceipt(draft: draft, recordedAt: Date(timeIntervalSince1970: 100))
    }

    func testNarrowConsumersShareOneStore() async throws {
        let store = OrderBookStore()
        let reader: any OrderHistoryReading = store
        let writer: any OrderSubmitting = store
        let confirmed = try await writer.submit(draft())
        let history = try await reader.history()
        XCTAssertEqual(history, [confirmed])
    }

    func testRepeatingSameDraftReturnsOriginalReceiptWithoutAnotherRecord() async throws {
        let store = OrderBookStore()
        let submitted = draft()
        let first = try await store.submit(submitted)
        let repeated = try await store.submit(submitted)
        XCTAssertEqual(repeated, first)
        let history = try await store.history()
        XCTAssertEqual(history.count, 1)
    }

    func testReusedIdentityWithDifferentPayloadIsRejected() async throws {
        let store = OrderBookStore()
        let original = draft()
        let confirmed = try await store.submit(original)
        do {
            _ = try await store.submit(draft(id: original.id, total: 900))
            XCTFail("An identity must not silently change its payload")
        } catch OrderBookError.conflictingIdentity { }
        let history = try await store.history()
        XCTAssertEqual(history, [confirmed])
    }

    func testInvalidDraftsDoNotEnterStore() async throws {
        let store = OrderBookStore()
        for invalid in [draft(reference: " "), draft(total: -1)] {
            do { _ = try await store.submit(invalid); XCTFail("Expected validation failure") }
            catch OrderBookError.invalidDraft { }
        }
        let history = try await store.history()
        XCTAssertTrue(history.isEmpty)
    }

    func testConcurrentRetriesCreateOnlyOneReceipt() async throws {
        let store = OrderBookStore()
        let submitted = draft()
        let all = try await withThrowingTaskGroup(of: OrderReceipt.self) { group in
            for _ in 0..<10 { group.addTask { try await store.submit(submitted) } }
            var values: [OrderReceipt] = []
            for try await value in group { values.append(value) }
            return values
        }
        XCTAssertEqual(Set(all.map(\.id)).count, 1)
        XCTAssertTrue(all.allSatisfy { $0 == all.first })
        let history = try await store.history()
        XCTAssertEqual(history.count, 1)
    }

    func testCancelledSubmissionAtEntryDoesNotCommit() async throws {
        let store = OrderBookStore()
        let submitted = draft()
        let task = Task { try await store.submit(submitted) }
        task.cancel() // MainActor task has not started yet.
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch is CancellationError { }
        let history = try await store.history()
        XCTAssertTrue(history.isEmpty)
    }

    func testHistoryModelWorksWithReaderThatHasNoWrites() async {
        let saved = receipt(draft())
        let model = OrderHistoryModel(reader: ReaderOnly(records: [saved]))
        await model.load().value
        XCTAssertEqual(model.records, [saved])
        XCTAssertTrue(model.hasLoaded)
    }

    func testFirstHistoryFailureDoesNotPretendToBeAnEmptySuccessfulLoad() async {
        let reader = ControlledReader()
        let model = OrderHistoryModel(reader: reader)
        let task = model.load()
        await reader.waitForArrival(1)
        await reader.complete(1, with: .failure(OrderBookError.offline))
        await task.value
        XCTAssertFalse(model.hasLoaded)
        XCTAssertTrue(model.records.isEmpty)
        XCTAssertTrue(model.warning?.contains("No records have been loaded") == true)
        XCTAssertFalse(model.isLoading)
    }

    func testHistoryReloadFailureKeepsPreviouslyLoadedRecords() async {
        let reader = ControlledReader()
        let model = OrderHistoryModel(reader: reader)
        let saved = receipt(draft())
        let first = model.load()
        await reader.waitForArrival(1)
        await reader.complete(1, with: .success([saved]))
        await first.value
        let second = model.load()
        await reader.waitForArrival(2)
        await reader.complete(2, with: .failure(OrderBookError.offline))
        await second.value
        XCTAssertEqual(model.records, [saved])
        XCTAssertTrue(model.hasLoaded)
        XCTAssertNotNil(model.warning)
    }

    func testOlderHistorySuccessCannotReplaceNewerSnapshot() async {
        let reader = ControlledReader()
        let model = OrderHistoryModel(reader: reader)
        let oldRecord = receipt(draft(reference: "old"))
        let newRecord = receipt(draft(reference: "new"))
        let old = model.load()
        await reader.waitForArrival(1)
        let new = model.load()
        await reader.waitForArrival(2)
        await reader.complete(2, with: .success([newRecord]))
        await new.value
        await reader.complete(1, with: .success([oldRecord]))
        await old.value
        XCTAssertEqual(model.records, [newRecord])
        XCTAssertNil(model.warning)
    }

    func testCancelledHistoryFailureDoesNotShowAnOfflineWarning() async {
        let reader = ControlledReader()
        let model = OrderHistoryModel(reader: reader)
        let task = model.load()
        await reader.waitForArrival(1)
        model.cancel()
        await reader.complete(1, with: .failure(OrderBookError.offline))
        await task.value
        XCTAssertFalse(model.isLoading)
        XCTAssertNil(model.warning)
    }

    func testEntryWorksWithSubmissionOnlyImplementation() async {
        let writer = WriterOnly()
        let submitted = draft()
        let model = OrderEntryModel(submitter: writer, draft: submitted)
        let success = await model.submit().value
        XCTAssertTrue(success)
        XCTAssertEqual(model.receipt?.draft, submitted)
        let calls = await writer.submissions
        XCTAssertEqual(calls, [submitted])
    }

    func testFailedSubmissionRetriesSameIdentityAndPayload() async {
        let writer = WriterOnly(failFirst: true)
        let submitted = draft()
        let model = OrderEntryModel(submitter: writer, draft: submitted)
        let failed = await model.submit().value
        XCTAssertFalse(failed)
        XCTAssertNil(model.receipt)
        XCTAssertNotNil(model.message)
        let recovered = await model.submit().value
        XCTAssertTrue(recovered)
        XCTAssertNil(model.message)
        let calls = await writer.submissions
        XCTAssertEqual(calls, [submitted, submitted])
    }

    func testPermanentIdentityConflictIsNotLabelledAsAnOutageToRetry() async {
        let store = OrderBookStore()
        let original = draft()
        _ = try? await store.submit(original)
        let model = OrderEntryModel(submitter: store, draft: draft(id: original.id, total: 900))
        let success = await model.submit().value
        XCTAssertFalse(success)
        XCTAssertNil(model.receipt)
        XCTAssertTrue(model.message?.contains("different payload") == true)
        XCTAssertFalse(model.message?.contains("retry") == true)
    }

    func testInvalidEntryNeverCallsSubmissionCapability() async {
        let writer = WriterOnly()
        let model = OrderEntryModel(submitter: writer, draft: draft(total: -1))
        let success = await model.submit().value
        XCTAssertFalse(success)
        let calls = await writer.submissions
        XCTAssertTrue(calls.isEmpty)
    }

    func testRepeatedTapsShareInFlightSubmissionAndConfirmedReceipt() async {
        let writer = WriterOnly()
        let model = OrderEntryModel(submitter: writer, draft: draft())
        let first = model.submit()
        let second = model.submit()
        let firstSuccess = await first.value
        let secondSuccess = await second.value
        let thirdSuccess = await model.submit().value
        XCTAssertTrue(firstSuccess && secondSuccess && thirdSuccess)
        let calls = await writer.submissions
        XCTAssertEqual(calls.count, 1)
    }

    func testReceiptWithWrongDraftIsNotConfirmed() async {
        let model = OrderEntryModel(submitter: WrongReceiptWriter(), draft: draft())
        let success = await model.submit().value
        XCTAssertFalse(success)
        XCTAssertNil(model.receipt)
        XCTAssertTrue(model.message?.contains("does not match") == true)
    }

    func testCancelledLateAcknowledgementCannotConfirmOldAttempt() async {
        let writer = ControlledWriter()
        let submitted = draft()
        let model = OrderEntryModel(submitter: writer, draft: submitted)
        let task = model.submit()
        await writer.waitForArrival()
        model.cancel()
        XCTAssertFalse(model.isSubmitting)
        await writer.complete(receipt(submitted))
        let success = await task.value
        XCTAssertFalse(success)
        XCTAssertNil(model.receipt)
        XCTAssertEqual(model.draft.id, submitted.id)
    }

    func testSuccessfulWriteIsIndependentOfHistoryOutage() async {
        let store = OrderBookStore()
        let reader = HistoryPort(store: store)
        await reader.setOffline(true)
        let history = OrderHistoryModel(reader: reader)
        let entry = OrderEntryModel(submitter: store, draft: draft())
        let success = await entry.submit().value
        await history.load().value
        XCTAssertTrue(success)
        XCTAssertNotNil(entry.receipt)
        XCTAssertNil(entry.message)
        XCTAssertNotNil(history.warning)
        let persisted = try? await store.history()
        XCTAssertEqual(persisted?.count, 1)
    }

    func testOnlyConfirmedEntryCanStartNewIdentity() async {
        let writer = WriterOnly()
        let model = OrderEntryModel(submitter: writer, draft: draft())
        let original = model.draft
        model.newDraft()
        XCTAssertEqual(model.draft, original)
        _ = await model.submit().value
        model.newDraft()
        XCTAssertNotEqual(model.draft.id, original.id)
        XCTAssertEqual(model.draft.reference, original.reference)
        XCTAssertNil(model.receipt)
    }
}

private struct ReaderOnly: OrderHistoryReading {
    let records: [OrderReceipt]
    func history() async throws -> [OrderReceipt] { records }
}
private actor WriterOnly: OrderSubmitting {
    var submissions: [OrderDraft] = []
    private var failFirst: Bool
    init(failFirst: Bool = false) { self.failFirst = failFirst }
    func submit(_ draft: OrderDraft) throws -> OrderReceipt {
        submissions.append(draft)
        if failFirst { failFirst = false; throw OrderBookError.offline }
        return OrderReceipt(draft: draft, recordedAt: Date(timeIntervalSince1970: 100))
    }
}
private struct WrongReceiptWriter: OrderSubmitting {
    func submit(_ draft: OrderDraft) async throws -> OrderReceipt {
        OrderReceipt(draft: OrderDraft(id: draft.id, reference: draft.reference + "-WRONG", totalPence: draft.totalPence), recordedAt: Date())
    }
}
private actor ControlledReader: OrderHistoryReading {
    private var count = 0
    private var pending: [Int: CheckedContinuation<[OrderReceipt], Error>] = [:]
    private var arrivals: [Int: CheckedContinuation<Void, Never>] = [:]
    func history() async throws -> [OrderReceipt] {
        count += 1
        let number = count
        return try await withCheckedThrowingContinuation { continuation in
            pending[number] = continuation
            arrivals.removeValue(forKey: number)?.resume()
        }
    }
    func waitForArrival(_ number: Int) async {
        if pending[number] != nil { return }
        await withCheckedContinuation { arrivals[number] = $0 }
    }
    func complete(_ number: Int, with result: Result<[OrderReceipt], Error>) {
        pending.removeValue(forKey: number)!.resume(with: result)
    }
}
private actor ControlledWriter: OrderSubmitting {
    private var pending: CheckedContinuation<OrderReceipt, Error>?
    private var arrival: CheckedContinuation<Void, Never>?
    func submit(_ draft: OrderDraft) async throws -> OrderReceipt {
        try await withCheckedThrowingContinuation { continuation in
            pending = continuation
            arrival?.resume(); arrival = nil
        }
    }
    func waitForArrival() async {
        if pending != nil { return }
        await withCheckedContinuation { arrival = $0 }
    }
    func complete(_ receipt: OrderReceipt) {
        pending?.resume(returning: receipt); pending = nil
    }
}
