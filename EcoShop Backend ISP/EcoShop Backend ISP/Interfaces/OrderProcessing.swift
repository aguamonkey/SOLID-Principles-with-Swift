//
//  OrderProcessing.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// INTERFACE SEGREGATION: Focused interface for order operations
// Each method has a clear, single responsibility
protocol OrderProcessing {
    func placeOrder(_ order: Order) async throws
    func updateOrder(_ order: Order) async throws
    func cancelOrder(_ orderId: String) async throws
    func getOrder(_ orderId: String) async throws -> Order?
    func findAllOrders() async throws -> [Order]
}
