//
//  ProductManager.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// ProductManager supports both smaller product capabilities for the app's full
// management screen, while read-only views can still depend on ProductReading.
class ProductManager: ProductManaging {
    private var products: [Product] = []
    
    func addProduct(_ product: Product) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        products.append(product)
    }
    
    func updateProduct(_ product: Product) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        } else {
            throw ProductError.notFound
        }
    }
    
    func deleteProduct(_ productId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        products.removeAll { $0.id == productId }
    }
    
    func findProduct(byId productId: String) async throws -> Product? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return products.first { $0.id == productId }
    }
    
    func findAllProducts() async throws -> [Product] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return products
    }
}

enum ProductError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Product not found"
        }
    }
}
