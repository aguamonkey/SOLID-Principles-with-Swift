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
    // Introduce a new product to the market. The birth of a new commodity star!
    func addProduct(_ product: Product)
    
    // Update the script when a product decides to change its act.
    func updateProduct(_ product: Product)
    
    // Sometimes a product must take its final bow and exit stage left.
    func deleteProduct(_ productId: String)
    
    // Shine a spotlight on a product, bringing it to center stage for all to see.
    func findProduct(byId productId: String) -> Product?
}
