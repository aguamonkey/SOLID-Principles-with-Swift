//
//
//  ContentView.swift
//  EcoShop Backend ISP
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

struct ContentView: View {
    // INTERFACE SEGREGATION: Each dependency is separate
    // This view can work with any implementation of these protocols
    var productManager: ProductManaging
    var orderProcessor: OrderProcessing
    var reviewHandler: ReviewHandling
    
    var body: some View {
        TabView {
            ProductManagementView(productManager: productManager)
                .tabItem {
                    Label("Products", systemImage: "cube.box")
                }
            
            OrderManagementView(orderProcessor: orderProcessor)
                .tabItem {
                    Label("Orders", systemImage: "cart")
                }
            
            ReviewManagementView(reviewHandler: reviewHandler)
                .tabItem {
                    Label("Reviews", systemImage: "star.circle")
                }
        }
    }
}

#Preview {
    ContentView(
        productManager: MockProductManager(),
        orderProcessor: MockOrderProcessor(),
        reviewHandler: MockReviewHandler()
    )
}
