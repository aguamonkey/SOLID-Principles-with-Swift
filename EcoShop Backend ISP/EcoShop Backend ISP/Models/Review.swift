//
//  Review.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// A model representing a customer review of a product.
/// INTERFACE SEGREGATION: Each model implements only what it needs
struct Review: IdentifiableWithStringID, Codable, Equatable {
    var id: String
    var productId: String
    var title: String
    var content: String
    var rating: Int
}
