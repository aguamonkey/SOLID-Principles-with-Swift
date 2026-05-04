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
    
    func testSuccessfulDataLoad() async {
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
        await viewModel.loadDataAsync(from: url)
        
        XCTAssertNotNil(viewModel.fetchedData)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockLogger.loggedMessages.contains { $0.level == .info })
    }
    
    func testFailedDataLoad() async {
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
        await viewModel.loadDataAsync(from: url)
        
        XCTAssertNil(viewModel.fetchedData)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(mockLogger.loggedMessages.contains { $0.level == .error })
    }
}
