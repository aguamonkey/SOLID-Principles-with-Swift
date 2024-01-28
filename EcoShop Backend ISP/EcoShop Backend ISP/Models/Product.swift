//
//  Product.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Models/Product.swift

/// A model representing a product in our e-commerce system.
/// In the grand scheme of our application, this is like a law about trade goods.
/// Each product has its own identity and characteristics, much like a citizen.
struct Product: IdentifiableWithStringID {
    var id: String          // Unique identifier for a product, akin to a social security number.
    var name: String        // Name of the product, as important as a person's name.
    var description: String // A description of the product, detailing its features and uses.
    var price: Double       // The price of the product, akin to the tax value.

    // Here we follow President Principle's vision:
    // Each entity should have its specialized role without extra burdens.
}
