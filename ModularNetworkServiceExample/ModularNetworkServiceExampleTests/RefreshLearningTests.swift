import XCTest
@testable import ModularNetworkServiceExample

final class RefreshingSignalStoreTests: XCTestCase {
    private let url = URL(string: "https://example.com/bulletin")!
    private let saved = SignalSnapshot(data: Data("saved".utf8), receivedAt: Date(timeIntervalSince1970: 100))

    func testCacheCanBeReadWhileTransportIsSuspended() async throws {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport, seed: [url: saved])
        let task = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(cached, saved)
        await transport.complete(1, with: .success(Data("fresh".utf8)))
        let updated = try await task.value
        XCTAssertEqual(updated.data, Data("fresh".utf8))
    }

    func testSuccessfulRefreshCommitsDataAndInjectedTimestamp() async throws {
        let transport = ControlledSignalTransport()
        let date = Date(timeIntervalSince1970: 200)
        let store = RefreshingSignalStore(transport: transport, now: { date })
        let task = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        await transport.complete(1, with: .success(Data("fresh".utf8)))
        let updated = try await task.value
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(updated, SignalSnapshot(data: Data("fresh".utf8), receivedAt: date))
        XCTAssertEqual(cached, updated)
    }

    func testOlderSuccessCannotOverwriteNewerCacheEvenWithoutCancellation() async throws {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport)
        let older = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        let newer = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(2)
        await transport.complete(2, with: .success(Data("new".utf8)))
        _ = try await newer.value
        await transport.complete(1, with: .success(Data("old".utf8)))
        do {
            _ = try await older.value
            XCTFail("An older request must be rejected at the cache boundary")
        } catch SignalRefreshError.superseded { } catch { XCTFail("Unexpected error: \(error)") }
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(cached?.data, Data("new".utf8))
    }

    func testOlderFailureIsSupersededAfterAnotherConsumerCommits() async throws {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport, seed: [url: saved])
        let older = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        let newer = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(2)
        await transport.complete(2, with: .success(Data("new".utf8)))
        _ = try await newer.value
        await transport.complete(1, with: .failure(URLError(.timedOut)))
        do {
            _ = try await older.value
            XCTFail("An obsolete failure must report supersession, not a current transport problem")
        } catch SignalRefreshError.superseded { } catch { XCTFail("Unexpected error: \(error)") }
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(cached?.data, Data("new".utf8))
    }

    func testNewerFailureDoesNotLetOlderSuccessReplaceSavedContent() async {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport, seed: [url: saved])
        let older = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        let newer = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(2)
        await transport.complete(2, with: .failure(URLError(.notConnectedToInternet)))
        if case .success = await newer.result { XCTFail("Expected the newest request to fail") }
        await transport.complete(1, with: .success(Data("old".utf8)))
        do {
            _ = try await older.value
            XCTFail("A newer failure must not revive older work")
        } catch SignalRefreshError.superseded { } catch { XCTFail("Unexpected error: \(error)") }
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(cached, saved)
    }

    func testCancellationPreventsLateTransportResponseFromEnteringCache() async {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport, seed: [url: saved])
        let task = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        task.cancel()
        // The fixture intentionally returns bytes despite cancellation.
        await transport.complete(1, with: .success(Data("late".utf8)))
        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError { } catch { XCTFail("Unexpected error: \(error)") }
        let cached = await store.cachedSignal(for: url)
        XCTAssertEqual(cached, saved)
    }

    func testDifferentURLsDoNotSupersedeEachOther() async throws {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport)
        let other = URL(string: "https://example.com/other")!
        let first = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        let second = Task { try await store.refreshSignal(for: other) }
        await transport.waitForRequest(2)
        await transport.complete(2, with: .success(Data("second".utf8)))
        _ = try await second.value
        await transport.complete(1, with: .success(Data("first".utf8)))
        _ = try await first.value
        let firstCache = await store.cachedSignal(for: url)
        let secondCache = await store.cachedSignal(for: other)
        XCTAssertEqual(firstCache?.data, Data("first".utf8))
        XCTAssertEqual(secondCache?.data, Data("second".utf8))
    }

    func testFailureDoesNotInventACacheEntry() async {
        let transport = ControlledSignalTransport()
        let store = RefreshingSignalStore(transport: transport)
        let task = Task { try await store.refreshSignal(for: url) }
        await transport.waitForRequest(1)
        await transport.complete(1, with: .failure(URLError(.notConnectedToInternet)))
        if case .success = await task.result { XCTFail("Expected failure") }
        let cached = await store.cachedSignal(for: url)
        XCTAssertNil(cached)
    }
}

@MainActor
final class RefreshViewModelTests: XCTestCase {
    private let url = URL(string: "https://example.com/bulletin")!
    private let saved = SignalSnapshot(data: Data("saved".utf8), receivedAt: Date(timeIntervalSince1970: 100))

    func testSavedContentIsVisibleBeforeRefreshFinishes() async {
        let repository = ControlledSignalRepository(seed: saved)
        let reporter = RecordingRefreshReporter()
        let model = RefreshViewModel(repository: repository, reporter: reporter, url: url)
        let task = model.refresh()
        await repository.transport.waitForRequest(1)
        XCTAssertEqual(model.snapshot, saved)
        XCTAssertTrue(model.isCached)
        XCTAssertEqual(model.phase, .refreshing)
        XCTAssertTrue(reporter.events.contains(.cacheShown))
        await repository.transport.complete(1, with: .success(Data("fresh".utf8)))
        await task.value
        XCTAssertEqual(model.snapshot?.data, Data("fresh".utf8))
        XCTAssertFalse(model.isCached)
        XCTAssertEqual(model.phase, .ready)
        XCTAssertEqual(reporter.events.last, .succeeded)
    }

    func testOfflineRefreshKeepsSavedContentAndProvidesAWarning() async {
        let repository = ControlledSignalRepository(seed: saved)
        let reporter = RecordingRefreshReporter()
        let model = RefreshViewModel(repository: repository, reporter: reporter, url: url)
        let task = model.refresh()
        await repository.transport.waitForRequest(1)
        await repository.transport.complete(1, with: .failure(URLError(.notConnectedToInternet)))
        await task.value
        XCTAssertEqual(model.snapshot, saved)
        XCTAssertTrue(model.isCached)
        XCTAssertEqual(model.phase, .failed)
        XCTAssertEqual(model.warning, "Refresh failed. Your saved signal is still available.")
        XCTAssertEqual(reporter.events.last, .failed)
    }

    func testFirstLoadFailureReportsThatNoSavedContentExists() async {
        let repository = ControlledSignalRepository(seed: nil)
        let model = RefreshViewModel(repository: repository, reporter: RecordingRefreshReporter(), url: url)
        let task = model.refresh()
        await repository.transport.waitForRequest(1)
        await repository.transport.complete(1, with: .failure(URLError(.notConnectedToInternet)))
        await task.value
        XCTAssertNil(model.snapshot)
        XCTAssertEqual(model.phase, .failed)
        XCTAssertEqual(model.warning, "No saved signal is available. Try refreshing again.")
    }

    func testCancelImmediatelyKeepsContentAndRejectsLateFailure() async {
        let repository = ControlledSignalRepository(seed: saved)
        let reporter = RecordingRefreshReporter()
        let model = RefreshViewModel(repository: repository, reporter: reporter, url: url)
        let task = model.refresh()
        await repository.transport.waitForRequest(1)
        model.cancelRefresh()
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertEqual(model.snapshot, saved)
        await repository.transport.complete(1, with: .failure(URLError(.cancelled)))
        await task.value
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertNil(model.warning)
        XCTAssertEqual(reporter.events.filter { $0 == .cancelled }.count, 1)
        XCTAssertFalse(reporter.events.contains(.failed))
    }

    func testLateOlderSuccessCannotReplaceNewerScreenContent() async {
        let repository = ControlledSignalRepository(seed: saved)
        let model = RefreshViewModel(repository: repository, reporter: RecordingRefreshReporter(), url: url)
        let older = model.refresh()
        await repository.transport.waitForRequest(1)
        let newer = model.refresh()
        await repository.transport.waitForRequest(2)
        await repository.transport.complete(2, with: .success(Data("new".utf8)))
        await newer.value
        await repository.transport.complete(1, with: .success(Data("old".utf8)))
        await older.value
        XCTAssertEqual(model.snapshot?.data, Data("new".utf8))
        XCTAssertEqual(model.phase, .ready)
        XCTAssertFalse(model.isCached)
    }

    func testLateOlderFailureCannotChangeNewerScreenOrEmitFailure() async {
        let repository = ControlledSignalRepository(seed: saved)
        let reporter = RecordingRefreshReporter()
        let model = RefreshViewModel(repository: repository, reporter: reporter, url: url)
        let older = model.refresh()
        await repository.transport.waitForRequest(1)
        let newer = model.refresh()
        await repository.transport.waitForRequest(2)
        await repository.transport.complete(2, with: .success(Data("new".utf8)))
        await newer.value
        await repository.transport.complete(1, with: .failure(URLError(.timedOut)))
        await older.value
        XCTAssertEqual(model.snapshot?.data, Data("new".utf8))
        XCTAssertNil(model.warning)
        XCTAssertEqual(model.phase, .ready)
        XCTAssertFalse(reporter.events.contains(.failed))
    }

    func testSupersededRefreshPreservesContentAndSuggestsRevalidation() async {
        let repository = ControlledSignalRepository(seed: saved)
        let reporter = RecordingRefreshReporter()
        let model = RefreshViewModel(repository: repository, reporter: reporter, url: url)
        let task = model.refresh()
        await repository.transport.waitForRequest(1)
        await repository.transport.complete(1, with: .failure(SignalRefreshError.superseded))
        await task.value
        XCTAssertEqual(model.snapshot, saved)
        XCTAssertEqual(model.phase, .superseded)
        XCTAssertNotNil(model.warning)
        XCTAssertEqual(reporter.events.last, .superseded)
    }
}

/// Explicit arrivals/completions test ordering, not scheduler timing or sleeps.
private actor ControlledSignalTransport: SignalTransport {
    private var count = 0
    private var requests: [Int: CheckedContinuation<Data, Error>] = [:]
    private var arrivals: [Int: CheckedContinuation<Void, Never>] = [:]

    func fetchSignal(from url: URL) async throws -> Data {
        count += 1
        let number = count
        return try await withCheckedThrowingContinuation { continuation in
            requests[number] = continuation
            arrivals.removeValue(forKey: number)?.resume()
        }
    }

    func waitForRequest(_ number: Int) async {
        if requests[number] != nil { return }
        await withCheckedContinuation { arrivals[number] = $0 }
    }

    func complete(_ number: Int, with result: Result<Data, Error>) {
        requests.removeValue(forKey: number)!.resume(with: result)
    }
}

/// Deliberately supplies no cancellation/ordering protection of its own.
private actor ControlledSignalRepository: SignalRepository {
    let transport = ControlledSignalTransport()
    private let seed: SignalSnapshot?
    init(seed: SignalSnapshot?) { self.seed = seed }
    func cachedSignal(for url: URL) -> SignalSnapshot? { seed }
    func refreshSignal(for url: URL) async throws -> SignalSnapshot {
        let data = try await transport.fetchSignal(from: url)
        return SignalSnapshot(data: data, receivedAt: Date(timeIntervalSince1970: 200))
    }
}

@MainActor
private final class RecordingRefreshReporter: RefreshReporting {
    var events: [RefreshEvent] = []
    func record(_ event: RefreshEvent) { events.append(event) }
}
