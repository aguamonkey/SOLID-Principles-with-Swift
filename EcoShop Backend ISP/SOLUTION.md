# Exercise solution: 04 · Interface Segregation

[Back to the lesson](README.md#exercise)

Keep the screen initializer focused on `ProductReading`:

```swift
import SwiftUI

@MainActor
struct CatalogView: View {
    @StateObject private var viewModel: ProductListViewModel

    init(productReader: ProductReading) {
        _viewModel = StateObject(
            wrappedValue: ProductListViewModel(productReader: productReader)
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error)
            } else {
                List(viewModel.products, id: \.id) { product in
                    VStack(alignment: .leading) {
                        Text(product.name)
                        Text("$\(product.price, specifier: "%.2f")")
                    }
                }
            }
        }
        .task { await viewModel.loadProducts() }
    }
}
```

This proposed screen needs only app target membership and a composition point that supplies a reader. Its view model already exists. The existing read-only catalog test verifies the loading path without adding write methods to its fixture; run the ISP unit tests.

A concrete product manager can still be passed as a reader. The narrower initializer describes what this consumer needs, not everything the supplied object can do. UI integration and visual checking remain part of implementing the exercise.
