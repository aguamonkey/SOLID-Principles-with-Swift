//
//  MockProductManager.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// MockProductManager supports the full product capability for previews.
// Tests can still provide narrower read-only or write-only doubles.
class MockProductManager: ProductManaging {
    private var mockProducts: [Product] = [
        Product(id: "1", name: "iPhone 15", description: "Latest iPhone", price: 999.99),
        Product(id: "2", name: "MacBook Pro", description: "Powerful laptop", price: 2499.99)
    ]
    
    func addProduct(_ product: Product) async throws {
        mockProducts.append(product)
    }
    
    func updateProduct(_ product: Product) async throws {
        if let index = mockProducts.firstIndex(where: { $0.id == product.id }) {
            mockProducts[index] = product
        }
    }
    
    func deleteProduct(_ productId: String) async throws {
        mockProducts.removeAll { $0.id == productId }
    }
    
    func findProduct(byId productId: String) async throws -> Product? {
        return mockProducts.first { $0.id == productId }
    }
    
    func findAllProducts() async throws -> [Product] {
        return mockProducts
    }
}
