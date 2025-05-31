//
//  OrderProcessor.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// INTERFACE SEGREGATION: Implements only OrderProcessing interface
class OrderProcessor: OrderProcessing {
    private var orders: [Order] = []
    
    func placeOrder(_ order: Order) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        orders.append(order)
    }
    
    func updateOrder(_ order: Order) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
        } else {
            throw OrderError.notFound
        }
    }
    
    func cancelOrder(_ orderId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        orders.removeAll { $0.id == orderId }
    }
    
    func getOrder(_ orderId: String) async throws -> Order? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return orders.first { $0.id == orderId }
    }
    
    func findAllOrders() async throws -> [Order] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return orders
    }
}

enum OrderError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Order not found"
        }
    }
}
