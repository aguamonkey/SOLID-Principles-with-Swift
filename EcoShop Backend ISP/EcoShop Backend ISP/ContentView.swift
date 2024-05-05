//
//
//  ContentView.swift
//  EcoShop Backend ISP
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

struct ContentView: View {
    var productManager: ProductManaging
    var orderProcessor: OrderProcessing
    var reviewHandler: ReviewHandling

    var body: some View {
        TabView {
            ProductManagementView(viewModel: ProductViewModel(productManager: productManager))
                .tabItem {
                    Label("Products", systemImage: "cube.box")
                }

            OrderManagementView(viewModel: OrderViewModel(orderProcessor: orderProcessor))
                .tabItem {
                    Label("Orders", systemImage: "cart")
                }

            ReviewManagementView(viewModel: ReviewViewModel(reviewHandler: reviewHandler))
                .tabItem {
                    Label("Reviews", systemImage: "star.circle")
                }
        }
    }
}
