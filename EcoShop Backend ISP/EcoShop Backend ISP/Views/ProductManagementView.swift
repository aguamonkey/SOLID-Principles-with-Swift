import SwiftUI

/// The stockroom combines reading and writing; neither view model needs both.
struct ProductManagementView: View {
    @StateObject private var listViewModel: ProductListViewModel
    @StateObject private var mutationViewModel: ProductMutationViewModel
    private let productWriter: ProductWriting
    private let onProductsChanged: () -> Void
    @State private var editingProduct: Product?
    @State private var addingProduct = false
    @State private var productToRemove: Product?
    @State private var revision = 0

    init(productReader: ProductReading, productWriter: ProductWriting, onProductsChanged: @escaping () -> Void = {}) {
        self.onProductsChanged = onProductsChanged
        _listViewModel = StateObject(wrappedValue: ProductListViewModel(productReader: productReader))
        _mutationViewModel = StateObject(wrappedValue: ProductMutationViewModel(productWriter: productWriter))
        self.productWriter = productWriter
    }

    var body: some View {
        LedgerPage(title: "Behind the\ncounter.", subtitle: "The stockroom / tend to the everyday goods.") {
            Button { addingProduct = true } label: { Label("Add an entry", systemImage: "plus") }
                .buttonStyle(LedgerButtonStyle()).accessibilityIdentifier("add-entry")
            LedgerStyle.label("STOCKROOM REGISTER")
            if listViewModel.isLoading { ProgressView("Opening the register…") }
            if let error = listViewModel.errorMessage {
                LedgerNotice(message: error) { revision += 1 }
            }
            if let error = mutationViewModel.errorMessage { LedgerNotice(message: error) }
            if !listViewModel.isLoading && listViewModel.products.isEmpty && listViewModel.errorMessage == nil {
                LedgerNotice(message: "No goods yet. Start the register with an entry.")
            }
            VStack(spacing: 0) {
                ForEach(Array(listViewModel.products.enumerated()), id: \.element.id) { index, product in
                    ProductLedgerRow(product: product, number: index + 1)
                    HStack {
                        Button("Edit") { editingProduct = product }
                            .accessibilityLabel("Edit \(product.name)")
                            .accessibilityIdentifier("edit-\(product.id)")
                        Spacer()
                        Button("Remove", role: .destructive) { productToRemove = product }
                            .accessibilityLabel("Remove \(product.name)")
                            .accessibilityIdentifier("remove-\(product.id)")
                    }.buttonStyle(.bordered).padding(.vertical, 10)
                }
            }.disabled(mutationViewModel.isSaving)
            LedgerNotice(message: "Sample shop / changes last for this session.")
        }
        .task(id: revision) { await listViewModel.loadProducts() }
        .sheet(isPresented: $addingProduct, onDismiss: { revision += 1; onProductsChanged() }) {
            ProductEditorView(productWriter: productWriter)
        }
        .sheet(item: $editingProduct, onDismiss: { revision += 1; onProductsChanged() }) { product in
            ProductEditorView(productWriter: productWriter, product: product)
        }
        .confirmationDialog("Remove \(productToRemove?.name ?? "this entry")?", isPresented: Binding(
            get: { productToRemove != nil }, set: { if !$0 { productToRemove = nil } }
        ), titleVisibility: .visible) {
            if let product = productToRemove {
                Button("Remove entry", role: .destructive) {
                    Task { if await mutationViewModel.deleteProduct(product.id) { revision += 1; onProductsChanged() } }
                }
            }
        }
    }
}

/// A prefilled value plus a writer is enough to edit. This form cannot read the catalog.
struct ProductEditorView: View {
    @StateObject private var viewModel: ProductMutationViewModel
    private let product: Product?
    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var priceError: String?
    @Environment(\.dismiss) private var dismiss

    init(productWriter: ProductWriting, product: Product? = nil) {
        _viewModel = StateObject(wrappedValue: ProductMutationViewModel(productWriter: productWriter))
        self.product = product
        _name = State(initialValue: product?.name ?? "")
        _description = State(initialValue: product?.description ?? "")
        _price = State(initialValue: product.map { String($0.price) } ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Entry details") {
                    TextField("Name", text: $name).accessibilityIdentifier("entry-name")
                    TextField("Description", text: $description, axis: .vertical)
                        .accessibilityIdentifier("entry-description")
                    TextField("Price in GBP (e.g. 12.50)", text: $price).keyboardType(.decimalPad)
                        .accessibilityIdentifier("entry-price")
                }
                if let error = priceError ?? viewModel.errorMessage { Text(error).foregroundStyle(LedgerStyle.accent) }
                Button(viewModel.isSaving ? "Saving…" : "Save entry") { Task { await save() } }
                    .accessibilityIdentifier("save-entry").disabled(viewModel.isSaving)
            }
            .scrollContentBackground(.hidden).background(LedgerStyle.paper)
            .navigationTitle(product == nil ? "New entry" : "Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(viewModel.isSaving) } }
        }
        .tint(LedgerStyle.ink).interactiveDismissDisabled(viewModel.isSaving)
    }

    private func save() async {
        priceError = nil
        guard let amount = Double(price.replacingOccurrences(of: ",", with: ".")), amount.isFinite, amount >= 0 else {
            priceError = "Enter a valid price of zero or more, such as 12.50."
            return
        }
        let entry = Product(id: product?.id ?? UUID().uuidString,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            description: description.trimmingCharacters(in: .whitespacesAndNewlines), price: amount)
        if await viewModel.saveProduct(entry, isNew: product == nil) { dismiss() }
    }
}
