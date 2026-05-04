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

        XCTAssertNotNil(viewModel.fetchedData)
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
        let repository = DelayedNetworkRepository()
        let viewModel = ContentViewModel(
            networkRepository: repository,
            logger: MockLoggingService()
        )

        let slowURL = URL(string: "https://test.com/slow")!
        let fastURL = URL(string: "https://test.com/fast")!

        let slowTask = viewModel.loadData(from: slowURL)
        let fastTask = viewModel.loadData(from: fastURL)

        await slowTask.value
        await fastTask.value

        XCTAssertEqual(viewModel.fetchedData, Data("fast".utf8))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testStartingNewLoadCancelsPreviousTask() async {
        let repository = DelayedNetworkRepository()
        let viewModel = ContentViewModel(
            networkRepository: repository,
            logger: MockLoggingService()
        )

        let slowURL = URL(string: "https://test.com/slow")!
        let fastURL = URL(string: "https://test.com/fast")!

        let slowTask = viewModel.loadData(from: slowURL)
        XCTAssertFalse(slowTask.isCancelled)

        let fastTask = viewModel.loadData(from: fastURL)

        XCTAssertTrue(slowTask.isCancelled)

        await slowTask.value
        await fastTask.value

        XCTAssertEqual(viewModel.fetchedData, Data("fast".utf8))
        XCTAssertFalse(viewModel.isLoading)
    }

    func testCancelledOlderFailureCannotOverwriteNewerSuccess() async {
        let repository = DelayedNetworkRepository()
        let viewModel = ContentViewModel(
            networkRepository: repository,
            logger: MockLoggingService()
        )

        let failingSlowURL = URL(string: "https://test.com/failing-slow")!
        let fastURL = URL(string: "https://test.com/fast")!

        let failingTask = viewModel.loadData(from: failingSlowURL)
        let fastTask = viewModel.loadData(from: fastURL)

        await failingTask.value
        await fastTask.value

        XCTAssertEqual(viewModel.fetchedData, Data("fast".utf8))
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}

private final class DelayedNetworkRepository: NetworkRepositoryProtocol {
    func getData(from url: URL) async throws -> Data {
        if url.absoluteString.contains("failing-slow") {
            try await Task.sleep(nanoseconds: 100_000_000)
            throw DataError.custom("Old request failed")
        }

        if url.absoluteString.contains("slow") {
            try await Task.sleep(nanoseconds: 100_000_000)
            return Data("slow".utf8)
        }

        try await Task.sleep(nanoseconds: 10_000_000)
        return Data("fast".utf8)
    }
}
