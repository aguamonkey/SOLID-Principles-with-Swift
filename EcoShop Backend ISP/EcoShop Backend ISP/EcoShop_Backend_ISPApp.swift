import SwiftUI

@main
struct EcoShop_Backend_ISPApp: App {
    // Composition owns the stores. Debug and Release run the same in-memory sample shop.
    let productManager: ProductManaging = ProductManager(products: ShopSamples.products)
    let orderProcessor: OrderProcessing = OrderProcessor(orders: ShopSamples.orders)
    let reviewHandler: ReviewHandling = ReviewHandler(reviews: ShopSamples.reviews)

    var body: some Scene {
        WindowGroup {
            ContentView(productManager: productManager, orderProcessor: orderProcessor, reviewHandler: reviewHandler)
        }
    }
}
