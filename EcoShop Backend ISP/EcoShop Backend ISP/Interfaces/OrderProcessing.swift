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
    func placeOrder(_ order: Order)
    func updateOrder(_ order: Order)
    func cancelOrder(_ orderId: String)
    func getOrder(_ orderId: String) -> Order?
    func findAllOrders() async -> [Order]
}
