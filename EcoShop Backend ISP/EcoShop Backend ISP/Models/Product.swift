//
//  Product.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// A model representing a product in our e-commerce system.
/// It stays limited to identity, coding, and equality so service protocols own behavior.
struct Product: IdentifiableWithStringID, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var price: Double
}
