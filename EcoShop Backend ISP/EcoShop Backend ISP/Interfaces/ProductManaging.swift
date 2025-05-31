//
//  ProductManaging.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// INTERFACE SEGREGATION: This protocol is focused only on product management
// We could further segregate this into smaller protocols if needed:
// - ProductReading (for read operations)
// - ProductWriting (for write operations)
// But for now, this level of segregation is appropriate

/// Protocol for managing products - follows ISP by grouping related operations
protocol ProductManaging {
    func addProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(_ productId: String) async throws
    func findProduct(byId productId: String) async throws -> Product?
    func findAllProducts() async throws -> [Product]
}

// INTERFACE SEGREGATION: Optional - We could segregate further if needed
protocol ProductReading {
    func findProduct(byId productId: String) async throws -> Product?
    func findAllProducts() async throws -> [Product]
}

protocol ProductWriting {
    func addProduct(_ product: Product) async throws
    func updateProduct(_ product: Product) async throws
    func deleteProduct(_ productId: String) async throws
}
