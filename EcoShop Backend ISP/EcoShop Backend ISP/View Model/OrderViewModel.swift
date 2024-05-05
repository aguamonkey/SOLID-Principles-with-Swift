//
//  OrderViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

class OrderViewModel: ObservableObject {
    private let orderProcessor: OrderProcessing

    @Published var orders: [Order] = []

    init(orderProcessor: OrderProcessing) {
        self.orderProcessor = orderProcessor
    }

    func loadOrders() async {
        let fetchedOrders = await orderProcessor.findAllOrders()
        DispatchQueue.main.async {
            self.orders = fetchedOrders
        }
    }

    func placeOrder(_ order: Order) {
        orderProcessor.placeOrder(order)
        Task {
            await loadOrders()
        }
    }

    func updateOrder(_ order: Order) {
        orderProcessor.updateOrder(order)
        Task {
            await loadOrders()
        }
    }

    func cancelOrder(_ orderId: String) {
        orderProcessor.cancelOrder(orderId)
        Task {
            await loadOrders()
        }
    }
}

