//
//  EcoShop_Backend_ISPTests.swift
//  EcoShop Backend ISPTests
//
//  Created by Gobias LTD on 31/12/2023.
//

import XCTest
@testable import EcoShop_Backend_ISP

final class EcoShop_Backend_ISPTests: XCTestCase {

    @MainActor
    func testProductViewModelDependsOnlyOnProductManaging() async {
        let productManager: ProductManaging = MockProductManager()
        let viewModel = ProductViewModel(productManager: productManager)
        
        await viewModel.loadProducts()
        
        XCTAssertEqual(viewModel.products.count, 2)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testProductReadingCanBeUsedWithoutWriteOperations() async throws {
        let catalog: ProductReading = ReadOnlyProductCatalog(products: [
            Product(id: "book", name: "SOLID Swift", description: "Design principles in practice", price: 24.99)
        ])
        
        let products = try await catalog.findAllProducts()
        
        XCTAssertEqual(products.map(\.name), ["SOLID Swift"])
    }
}

private struct ReadOnlyProductCatalog: ProductReading {
    let products: [Product]
    
    func findProduct(byId productId: String) async throws -> Product? {
        products.first { $0.id == productId }
    }
    
    func findAllProducts() async throws -> [Product] {
        products
    }
}
