//
//  ProductViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

// INTERFACE SEGREGATION: ViewModel depends only on ProductManaging interface
// It doesn't need to know about orders or reviews
@MainActor
class ProductViewModel: ObservableObject {
    private let productManager: ProductManaging // ISP: Depends only on the interface it uses
    
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(productManager: ProductManaging) {
        self.productManager = productManager
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // ISP benefit: We only call methods from ProductManaging
            let loadedProducts = try await productManager.findAllProducts()
            self.products = loadedProducts
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addProduct(_ product: Product) async {
        do {
            try await productManager.addProduct(product)
            await loadProducts()
        } catch {
            errorMessage = "Failed to add product: \(error.localizedDescription)"
        }
    }
    
    func deleteProduct(_ productId: String) async {
        do {
            try await productManager.deleteProduct(productId)
            await loadProducts()
        } catch {
            errorMessage = "Failed to delete product: \(error.localizedDescription)"
        }
    }
}
