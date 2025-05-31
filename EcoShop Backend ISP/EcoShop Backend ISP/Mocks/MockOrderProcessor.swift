//
//  MockOrderProcessor.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// INTERFACE SEGREGATION: Separate mock for order processing
class MockOrderProcessor: OrderProcessing {
    private var mockOrders: [Order] = [
        Order(id: "1", productIds: ["1", "2"], orderDate: Date(), totalAmount: 3499.98)
    ]
    
    func placeOrder(_ order: Order) async throws {
        mockOrders.append(order)
    }
    
    func updateOrder(_ order: Order) async throws {
        if let index = mockOrders.firstIndex(where: { $0.id == order.id }) {
            mockOrders[index] = order
        }
    }
    
    func cancelOrder(_ orderId: String) async throws {
        mockOrders.removeAll { $0.id == orderId }
    }
    
    func getOrder(_ orderId: String) async throws -> Order? {
        return mockOrders.first { $0.id == orderId }
    }
    
    func findAllOrders() async throws -> [Order] {
        return mockOrders
    }
}
