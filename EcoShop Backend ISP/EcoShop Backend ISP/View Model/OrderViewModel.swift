//
//  OrderViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

// Order UI policy depends on the smallest service shape that can support it.
@MainActor
class OrderViewModel: ObservableObject {
    private let orderProcessor: OrderProcessing
    
    @Published var orders: [Order] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(orderProcessor: OrderProcessing) {
        self.orderProcessor = orderProcessor
    }
    
    func loadOrders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedOrders = try await orderProcessor.findAllOrders()
            self.orders = fetchedOrders
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func placeOrder(_ order: Order) async {
        do {
            try await orderProcessor.placeOrder(order)
            await loadOrders()
        } catch {
            errorMessage = "Failed to place order: \(error.localizedDescription)"
        }
    }
    
    func updateOrder(_ order: Order) async {
        do {
            try await orderProcessor.updateOrder(order)
            await loadOrders()
        } catch {
            errorMessage = "Failed to update order: \(error.localizedDescription)"
        }
    }
    
    func cancelOrder(_ orderId: String) async {
        do {
            try await orderProcessor.cancelOrder(orderId)
            await loadOrders()
        } catch {
            errorMessage = "Failed to cancel order: \(error.localizedDescription)"
        }
    }
}
