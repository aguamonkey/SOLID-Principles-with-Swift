//
//  Order.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Models/Order.swift

/// Represents an order in our e-commerce platform.
/// Think of it as an executive order issued by President Principle.
/// It's a directive that mobilizes products according to customer demand.
struct Order: IdentifiableWithStringID {
    var id: String            // The order ID, like a bill number in congress.
    var productIds: [String]  // List of products being ordered, the content of the bill.
    var orderDate: Date       // The date the order was placed, akin to a bill's signing date.
    var totalAmount: Double   // The total amount of the order, similar to the budget allocated for the bill.

    // Orders, as per President Principle's vision, should only contain what is necessary
    // to fulfill their purpose, nothing more, nothing less.
}
