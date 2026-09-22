import Combine
import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {
    private let productReader: ProductReading
    private var loadVersion = 0
    @Published private(set) var products: [Product] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    init(productReader: ProductReading) { self.productReader = productReader }

    func loadProducts() async {
        // A newer refresh must be allowed to replace a cancelled or slower read.
        loadVersion += 1
        let version = loadVersion
        isLoading = true
        errorMessage = nil
        defer { if version == loadVersion { isLoading = false } }
        do {
            let loaded = try await productReader.findAllProducts()
            if version == loadVersion { products = loaded }
        } catch is CancellationError { }
        catch {
            if version == loadVersion { errorMessage = "Could not open the register: \(error.localizedDescription)" }
        }
    }
}

/// A writer never reloads the catalog. The composing screen coordinates refreshes.
@MainActor
final class ProductMutationViewModel: ObservableObject {
    private let productWriter: ProductWriting
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSaving = false

    init(productWriter: ProductWriting) { self.productWriter = productWriter }

    func saveProduct(_ product: Product, isNew: Bool) async -> Bool {
        guard !isSaving else { return false }
        guard !product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !product.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              product.price.isFinite, product.price >= 0 else {
            errorMessage = "Enter a name, a description and a valid price of zero or more."
            return false
        }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            if isNew { try await productWriter.addProduct(product) }
            else { try await productWriter.updateProduct(product) }
            return true
        } catch {
            errorMessage = "Could not save the entry: \(error.localizedDescription)"
            return false
        }
    }

    @discardableResult
    func addProduct(_ product: Product) async -> Bool { await saveProduct(product, isNew: true) }

    @discardableResult
    func deleteProduct(_ productId: String) async -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await productWriter.deleteProduct(productId)
            return true
        } catch {
            errorMessage = "Could not remove the entry: \(error.localizedDescription)"
            return false
        }
    }
}
