//
//  Product.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// A model representing a product in our e-commerce system.
/// INTERFACE SEGREGATION: This model only implements the protocols it needs (IdentifiableWithStringID)
/// It doesn't implement any unnecessary interfaces
struct Product: IdentifiableWithStringID, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var price: Double
}
