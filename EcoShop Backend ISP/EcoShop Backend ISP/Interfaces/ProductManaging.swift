//
//  ProductManaging.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Interfaces/ProductManaging.swift

/// The constitution of product governance, authored by President Interface S. Principle.
/// This document declares the rights and duties of all entities that manage our marketplace's products.
protocol ProductManaging {
    func addProduct(_ product: Product)
    func updateProduct(_ product: Product)
    func deleteProduct(_ productId: String)
    func findProduct(byId productId: String) -> Product?
    func findAllProducts() async -> [Product]  // Asynchronously retrieve all products
}
