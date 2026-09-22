# Exercise solution: 04 · Interface Segregation

[Back to the lesson](README.md#exercise)

The new screen still consumes a catalog capability. A price filter does not justify adding write methods or inventing another service protocol.

```swift
import SwiftUI

struct UsefulUnder15View: View {
    @StateObject private var viewModel: ProductListViewModel

    init(productReader: ProductReading) {
        _viewModel = StateObject(
            wrappedValue: ProductListViewModel(productReader: productReader)
        )
    }

    private var affordableProducts: [Product] {
        viewModel.products.filter { $0.price <= 15 }
    }

    var body: some View {
        LedgerPage(title: "Useful under £15", subtitle: "Small everyday essentials.") {
            if viewModel.isLoading {
                ProgressView("Opening the register…")
            } else if let error = viewModel.errorMessage {
                LedgerNotice(message: error) {
                    Task { await viewModel.loadProducts() }
                }
            } else if affordableProducts.isEmpty {
                LedgerNotice(message: "No goods at £15 or less today.")
            } else {
                ForEach(Array(affordableProducts.enumerated()), id: \.element.id) { index, product in
                    ProductLedgerRow(product: product, number: index + 1)
                }
            }
        }
        .task { await viewModel.loadProducts() }
    }
}
```

Add the file to the app target and compose it with the existing product manager as a reader. A read-only fixture is sufficient for previews and tests. For prices £9, £15, and £22, expect the first two entries to appear; also check no qualifying products, failure, and retry.

For this small display rule, a computed property is reasonable. If the filtering acquires sorting, search, or other policy, move it into a presentation model and test those behaviours there. That model should still accept `ProductReading`.

Compare the initializer to the production [CatalogView](EcoShop%20Backend%20ISP/Views/CatalogView.swift). Its dependency has not grown just because presentation changed.
