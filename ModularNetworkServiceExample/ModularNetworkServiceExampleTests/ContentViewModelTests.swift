//
//  ContentViewModelTests.swift
//  ModularNetworkServiceExampleTests
//
//  Created by Joshua Browne on 07/06/2025.
//

import XCTest
@testable import ModularNetworkServiceExample

@MainActor
final class ContentViewModelTests: XCTestCase {

    func testViewModelLoadsDataThroughInjectedNetworkAbstractions() async {
        // Arrange
        let mockLogger = MockLoggingService()
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockData = Data("Test data".utf8)

        let useCase = FetchDataUseCase(
            networkService: mockNetworkService,
            logger: mockLogger
        )
        let repository = NetworkRepository(fetchDataUseCase: useCase)
        let viewModel = ContentViewModel(
            networkRepository: repository,
            logger: mockLogger
        )

        let url = URL(string: "https://test.com")!
        await viewModel.loadData(from: url).value

        XCTAssertEqual(viewModel.fetchedData, Data("Test data".utf8))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockLogger.loggedMessages.contains { $0.level == .info })
    }

    func testViewModelReportsErrorsThroughInjectedNetworkAbstractions() async {
        // Arrange
        let mockLogger = MockLoggingService()
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldFail = true

        let useCase = FetchDataUseCase(
            networkService: mockNetworkService,
            logger: mockLogger
        )
        let repository = NetworkRepository(fetchDataUseCase: useCase)
        let viewModel = ContentViewModel(
            networkRepository: repository,
            logger: mockLogger
        )

        let url = URL(string: "https://test.com")!
        await viewModel.loadData(from: url).value

        XCTAssertNil(viewModel.fetchedData)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockLogger.loggedMessages.contains { $0.level == .error })
    }

    func testLatestDataLoadWinsWhenRequestsOverlap() async {
        let repository = ControlledRepository()
        let model = ContentViewModel(networkRepository: repository, logger: MockLoggingService())
        let first = URL(string: "https://example.com/first")!
        let second = URL(string: "https://example.com/second")!
        let oldTask = model.loadData(from: first)
        await repository.waitForRequest(first)
        let newTask = model.loadData(from: second)
        await repository.waitForRequest(second)
        XCTAssertTrue(oldTask.isCancelled)
        await repository.complete(second, with: .success(Data("new".utf8)))
        await newTask.value
        // This fixture deliberately ignores cancellation and completes late.
        await repository.complete(first, with: .success(Data("old".utf8)))
        await oldTask.value
        XCTAssertEqual(model.fetchedData, Data("new".utf8))
        XCTAssertFalse(model.isLoading)
    }

    func testCancelledOlderFailureCannotOverwriteNewerSuccess() async {
        let repository = ControlledRepository()
        let logger = MockLoggingService()
        let model = ContentViewModel(networkRepository: repository, logger: logger)
        let first = URL(string: "https://example.com/first")!
        let second = URL(string: "https://example.com/second")!
        let oldTask = model.loadData(from: first)
        await repository.waitForRequest(first)
        let newTask = model.loadData(from: second)
        await repository.waitForRequest(second)
        await repository.complete(second, with: .success(Data("new".utf8)))
        await newTask.value
        await repository.complete(first, with: .failure(DataError.custom("Stale error")))
        await oldTask.value
        XCTAssertEqual(model.fetchedData, Data("new".utf8))
        XCTAssertNil(model.errorMessage)
        XCTAssertTrue(logger.loggedMessages.isEmpty)
    }

    func testExplicitCancellationIgnoresLateFailure() async {
        let repository = ControlledRepository()
        let logger = MockLoggingService()
        let model = ContentViewModel(networkRepository: repository, logger: logger)
        let url = URL(string: "https://example.com")!
        let task = model.loadData(from: url)
        await repository.waitForRequest(url)
        model.cancelLoad()
        XCTAssertTrue(task.isCancelled)
        XCTAssertFalse(model.isLoading)
        XCTAssertTrue(model.wasCancelled)
        await repository.complete(url, with: .failure(URLError(.cancelled)))
        await task.value
        XCTAssertNil(model.errorMessage)
        XCTAssertNil(model.fetchedData)
        XCTAssertTrue(logger.loggedMessages.isEmpty)
    }

    func testStartingLoadClearsPreviousPayloadImmediately() async {
        let model = ContentViewModel(networkRepository: NetworkComposition.repository(for: .sample, logger: MockLoggingService()), logger: MockLoggingService())
        await model.loadData(from: NetworkComposition.demoURL).value
        XCTAssertNotNil(model.fetchedData)
        let task = model.loadData(from: NetworkComposition.demoURL)
        XCTAssertTrue(model.isLoading)
        XCTAssertNil(model.fetchedData)
        await task.value
        XCTAssertEqual(model.fetchedData, SampleNetworkService.payload)
    }

    func testErrorDescriptionSurvivesTheErrorProtocol() {
        let error: Error = DataError.custom("Readable failure")
        XCTAssertEqual(error.localizedDescription, "Readable failure")
    }
}

/// Explicit completions make overlap tests deterministic; no timing sleeps required.
private actor ControlledRepository: NetworkRepositoryProtocol {
    private var requests: [URL: CheckedContinuation<Data, Error>] = [:]
    private var arrivals: [URL: CheckedContinuation<Void, Never>] = [:]

    func getData(from url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            requests[url] = continuation
            arrivals.removeValue(forKey: url)?.resume()
        }
    }

    func waitForRequest(_ url: URL) async {
        if requests[url] != nil { return }
        await withCheckedContinuation { arrivals[url] = $0 }
    }

    func complete(_ url: URL, with result: Result<Data, Error>) {
        requests.removeValue(forKey: url)!.resume(with: result)
    }
}
