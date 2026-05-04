//
//  ModularNetworkServiceExampleTests.swift
//  ModularNetworkServiceExampleTests
//
//  Created by Joshua Browne on 24/03/2025.
//

import XCTest
@testable import ModularNetworkServiceExample

final class ModularNetworkServiceExampleTests: XCTestCase {

    @MainActor
    func testContainerResolvesViewModelThroughAbstractions() {
        let viewModel = DIContainer.shared.resolve(ContentViewModel.self)
        
        XCTAssertNil(viewModel.fetchedData)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
