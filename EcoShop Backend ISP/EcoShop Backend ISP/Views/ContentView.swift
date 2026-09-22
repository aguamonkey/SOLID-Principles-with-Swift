import SwiftUI

struct ContentView: View {
    // Only the composition point needs all capabilities. Each child receives its own.
    let productManager: ProductManaging
    let orderProcessor: OrderProcessing
    let reviewHandler: ReviewHandling

    @State private var productRevision = 0

    var body: some View {
        TabView {
            CatalogView(productReader: productManager, refreshVersion: productRevision)
                .tabItem { Label("Goods", systemImage: "book.closed") }
            ProductManagementView(productReader: productManager, productWriter: productManager) { productRevision += 1 }
                .tabItem { Label("Stockroom", systemImage: "shippingbox") }
            OrderManagementView(orderProcessor: orderProcessor)
                .tabItem { Label("Orders", systemImage: "receipt") }
            ReviewManagementView(reviewHandler: reviewHandler)
                .tabItem { Label("Reviews", systemImage: "text.bubble") }
        }
        .tint(LedgerStyle.ink)
    }
}

#Preview {
    ContentView(productManager: MockProductManager(), orderProcessor: MockOrderProcessor(), reviewHandler: MockReviewHandler())
}
