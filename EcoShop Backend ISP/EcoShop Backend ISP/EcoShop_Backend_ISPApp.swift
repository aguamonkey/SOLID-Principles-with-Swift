//
//  EcoShop_Backend_ISPApp.swift
//  EcoShop Backend ISP
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

@main
struct EcoShop_Backend_ISPApp: App {
    // INTERFACE SEGREGATION: We can easily swap implementations
    // For example, we could use real services in production and mocks in development
    #if DEBUG
    let productManager: ProductManaging = MockProductManager()
    let orderProcessor: OrderProcessing = MockOrderProcessor()
    let reviewHandler: ReviewHandling = MockReviewHandler()
    #else
    let productManager: ProductManaging = ProductManager()
    let orderProcessor: OrderProcessing = OrderProcessor()
    let reviewHandler: ReviewHandling = ReviewHandler()
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                productManager: productManager,
                orderProcessor: orderProcessor,
                reviewHandler: reviewHandler
            )
        }
    }
}
