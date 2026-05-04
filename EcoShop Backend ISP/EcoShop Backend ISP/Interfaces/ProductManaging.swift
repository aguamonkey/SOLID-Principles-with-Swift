//
//  ProductManaging.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// Read-only access for product views that only display catalog data.
protocol ProductReading {
    func findProduct(byId productId: String) async throws -> Product?
    func findAllProducts() async throws -> [Product]
}

/// Write access for product flows that create, edit, or delete catalog data.
protocol ProductWriting {
    func addProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(_ productId: String) async throws
}

/// Full product management composes the smaller capabilities for callers that need both.
protocol ProductManaging: ProductReading, ProductWriting {}
