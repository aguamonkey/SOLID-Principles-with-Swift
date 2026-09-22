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
    @MainActor
    func testCatalogScreenAcceptsAReadOnlyImplementation() {
        // Compile-time evidence: no ProductWriting conformance or stub methods.
        _ = CatalogView(productReader: ReadOnlyProductCatalog(products: []))
    }

    @MainActor
    func testEditorAcceptsAWriteOnlyImplementation() {
        _ = ProductEditorView(productWriter: WriteOnlyProductSink())
    }

    @MainActor
    func testWriterCanEditWithoutReadingTheCatalog() async {
        let sink = WriteOnlyProductSink()
        let model = ProductMutationViewModel(productWriter: sink)
        var product = ShopSamples.products[0]
        product.price = 18
        let saved = await model.saveProduct(product, isNew: false)
        XCTAssertTrue(saved)
        XCTAssertEqual(sink.updatedProducts, [product])
        XCTAssertTrue(sink.addedProducts.isEmpty)
    }

    @MainActor
    func testInvalidProductNeverReachesWriter() async {
        let sink = WriteOnlyProductSink()
        let model = ProductMutationViewModel(productWriter: sink)
        for price in [-1, Double.infinity, Double.nan] {
            var product = ShopSamples.products[0]
            product.price = price
            let saved = await model.addProduct(product)
            XCTAssertFalse(saved)
        }
        var blank = ShopSamples.products[0]
        blank.name = "  \n"
        let saved = await model.addProduct(blank)
        XCTAssertFalse(saved)
        XCTAssertTrue(sink.addedProducts.isEmpty)
        XCTAssertNotNil(model.errorMessage)
    }

    @MainActor
    func testFailedWriteReportsFailureAndCanRetry() async {
        let sink = WriteOnlyProductSink()
        sink.shouldFail = true
        let model = ProductMutationViewModel(productWriter: sink)
        let failed = await model.addProduct(ShopSamples.products[0])
        XCTAssertFalse(failed)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isSaving)
        sink.shouldFail = false
        let saved = await model.addProduct(ShopSamples.products[0])
        XCTAssertTrue(saved)
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(sink.addedProducts.count, 1)
    }

    @MainActor
    func testFailedReadCanRetryWithoutAnyWriteCapability() async {
        let reader = RetryReader()
        let model = ProductListViewModel(productReader: reader)
        await model.loadProducts()
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        await model.loadProducts()
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.products, ShopSamples.products)
    }

    @MainActor
    func testEmptyCatalogIsASuccessfulRead() async {
        let model = ProductListViewModel(productReader: ReadOnlyProductCatalog(products: []))
        await model.loadProducts()
        XCTAssertTrue(model.products.isEmpty)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor
    func testSharedStoreReflectsAddsEditsAndRemovalsOnReload() async {
        let store = ProductManager()
        let reader = ProductListViewModel(productReader: store)
        let writer = ProductMutationViewModel(productWriter: store)
        var product = ShopSamples.products[0]
        await writer.addProduct(product)
        await reader.loadProducts()
        XCTAssertEqual(reader.products, [product])
        product.price = 21
        let updated = await writer.saveProduct(product, isNew: false)
        XCTAssertTrue(updated)
        await reader.loadProducts()
        XCTAssertEqual(reader.products, [product])
        await writer.deleteProduct(product.id)
        await reader.loadProducts()
        XCTAssertTrue(reader.products.isEmpty)
    }

    @MainActor
    func testOrderSaveReportsFailureWithoutPretendingSuccess() async {
        let model = OrderViewModel(orderProcessor: FailingOrderProcessor())
        let saved = await model.placeOrder(ShopSamples.orders[0])
        XCTAssertFalse(saved)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertTrue(model.orders.isEmpty)
    }

    @MainActor
    func testReviewSaveReportsFailureWithoutPretendingSuccess() async {
        let model = ReviewViewModel(reviewHandler: FailingReviewHandler())
        let saved = await model.addReview(ShopSamples.reviews[0])
        XCTAssertFalse(saved)
        XCTAssertNotNil(model.errorMessage)
        XCTAssertTrue(model.reviews.isEmpty)
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
    var shouldFail = false
    private(set) var updatedProducts: [Product] = []
    private(set) var addedProducts: [Product] = []
    private(set) var deletedProductIds: [String] = []
    
    func addProduct(_ product: Product) async throws {
        if shouldFail { throw FixtureError.unavailable }
        addedProducts.append(product)
    }
    
    func updateProduct(_ product: Product) async throws { updatedProducts.append(product) }
    
    func deleteProduct(_ productId: String) async throws {
        deletedProductIds.append(productId)
    }
}

private enum FixtureError: Error { case unavailable }

private final class RetryReader: ProductReading {
    private var attempts = 0
    func findProduct(byId productId: String) async throws -> Product? { nil }
    func findAllProducts() async throws -> [Product] {
        attempts += 1
        if attempts == 1 { throw FixtureError.unavailable }
        return ShopSamples.products
    }
}

private final class FailingOrderProcessor: MockOrderProcessor {
    override func placeOrder(_ order: Order) async throws { throw FixtureError.unavailable }
}

private final class FailingReviewHandler: MockReviewHandler {
    override func addReview(_ review: Review) async throws { throw FixtureError.unavailable }
}
