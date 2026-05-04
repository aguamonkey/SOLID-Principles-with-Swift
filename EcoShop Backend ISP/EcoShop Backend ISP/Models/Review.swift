//
//  Review.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// A model representing a customer review of a product.
/// Review behavior lives behind review services, keeping this value easy to persist and test.
struct Review: IdentifiableWithStringID, Codable, Equatable {
    var id: String
    var productId: String
    var title: String
    var content: String
    var rating: Int
}
