import SwiftUI

/// This screen can be constructed with a reader that has no write operations.
struct CatalogView: View {
    @StateObject private var viewModel: ProductListViewModel

    private let refreshVersion: Int

    init(productReader: ProductReading, refreshVersion: Int = 0) {
        self.refreshVersion = refreshVersion
        _viewModel = StateObject(wrappedValue: ProductListViewModel(productReader: productReader))
    }

    var body: some View {
        LedgerPage(title: "The everyday\nstore.", subtitle: "Useful goods. A little less throwaway.") {
            LedgerStyle.label("THE GOODS REGISTER")
            LedgerStyle.divider
            if viewModel.isLoading {
                ProgressView("Opening the register…")
            } else if let error = viewModel.errorMessage {
                LedgerNotice(message: error) { Task { await viewModel.loadProducts() } }
            } else if viewModel.products.isEmpty {
                LedgerNotice(message: "The shelves are empty. Add your first goods in the Stockroom.")
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
                        ProductLedgerRow(product: product, number: index + 1)
                    }
                }
                Text("Keep the useful things.").font(.system(.title3, design: .serif).italic())
                    .foregroundStyle(LedgerStyle.accent)
                LedgerStyle.label("\(viewModel.products.count) ENTRIES / GBP PER ITEM")
            }
            LedgerNotice(message: "A catalog for browsing. Product changes live in the Stockroom.")
        }
        .task(id: refreshVersion) { await viewModel.loadProducts() }
        .refreshable { await viewModel.loadProducts() }
    }
}
