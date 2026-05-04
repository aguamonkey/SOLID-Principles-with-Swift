//
//  OrderProcessing.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Order screens should not need product or review APIs just to manage checkout state.
protocol OrderProcessing {
    func placeOrder(_ order: Order) async throws
    func updateOrder(_ order: Order) async throws
    func cancelOrder(_ orderId: String) async throws
    func getOrder(_ orderId: String) async throws -> Order?
    func findAllOrders() async throws -> [Order]
}
