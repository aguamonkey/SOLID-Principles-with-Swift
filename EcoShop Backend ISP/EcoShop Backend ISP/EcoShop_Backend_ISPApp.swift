//
//  EcoShop_Backend_ISPApp.swift
//  EcoShop Backend ISP
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

@main
struct EcoShop_Backend_ISPApp: App {
    // Mock dependencies for demonstration purposes
    let productManager = MockProductManager()
    let orderProcessor = MockOrderProcessor()
    let reviewHandler = MockReviewHandler()

    var body: some Scene {
        WindowGroup {
            ContentView(productManager: productManager, orderProcessor: orderProcessor, reviewHandler: reviewHandler)
        }
    }
}
