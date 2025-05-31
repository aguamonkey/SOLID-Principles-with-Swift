//
//  Order.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

/// Represents an order in our e-commerce platform.
/// INTERFACE SEGREGATION: Implements only the protocols needed for an Order
struct Order: IdentifiableWithStringID, Codable, Equatable {
    var id: String
    var productIds: [String]
    var orderDate: Date
    var totalAmount: Double
}
