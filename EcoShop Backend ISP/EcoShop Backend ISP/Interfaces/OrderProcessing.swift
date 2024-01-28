//
//  OrderProcessing.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Interfaces/OrderProcessing.swift

/// The legislative framework for order orchestration, a pivotal part of President Principle's grand economic plan.
/// It defines how orders shall waltz through our system, ensuring a ballet of efficiency and precision.
protocol OrderProcessing {
    // Create a new order, initiating the dance of commerce.
    func placeOrder(_ order: Order)
    
    // Adjust the choreography of an existing order when the dance must change.
    func updateOrder(_ order: Order)
    
    // Cancel an order, stopping the music and clearing the dance floor.
    func cancelOrder(_ orderId: String)
    
    // Retrieve the details of an order, recounting the steps of the dance.
    func getOrder(_ orderId: String) -> Order?
}
