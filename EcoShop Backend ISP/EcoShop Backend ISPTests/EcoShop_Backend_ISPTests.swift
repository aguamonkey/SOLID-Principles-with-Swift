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
    func testProductListViewModelDependsOnlyOnProductReading() async {
        let productReader: ProductReading = ReadOnlyProductCatalog(products: [
            Product(id: "book", name: "SOLID Swift", description: "Design principles in practice", price: 24.99)
        ])
        let viewModel = ProductListViewModel(productReader: productReader)
        
        await viewModel.loadProducts()
        
        XCTAssertEqual(viewModel.products.map(\.name), ["SOLID Swift"])
        XCTAssertNil(viewModel.errorMessage)
    }

    func testProductReadingCanBeUsedWithoutWriteOperations() async throws {
        let catalog: ProductReading = ReadOnlyProductCatalog(products: [
            Product(id: "book", name: "SOLID Swift", description: "Design principles in practice", price: 24.99)
        ])
        
        let products = try await catalog.findAllProducts()
        
        XCTAssertEqual(products.map(\.name), ["SOLID Swift"])
    }

    @MainActor
    func testProductMutationViewModelDependsOnlyOnProductWriting() async {
        let productWriter = WriteOnlyProductSink()
        let viewModel = ProductMutationViewModel(productWriter: productWriter)
        let product = Product(id: "pen", name: "Refactor Pen", description: "Writes small protocols", price: 3.99)

        await viewModel.addProduct(product)
        await viewModel.deleteProduct(product.id)

        XCTAssertEqual(productWriter.addedProducts.map(\.id), ["pen"])
        XCTAssertEqual(productWriter.deletedProductIds, ["pen"])
        XCTAssertNil(viewModel.errorMessage)
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

private final class WriteOnlyProductSink: ProductWriting {
    private(set) var addedProducts: [Product] = []
    private(set) var deletedProductIds: [String] = []
    
    func addProduct(_ product: Product) async throws {
        addedProducts.append(product)
    }
    
    func updateProduct(_ product: Product) async throws {}
    
    func deleteProduct(_ productId: String) async throws {
        deletedProductIds.append(productId)
    }
}
