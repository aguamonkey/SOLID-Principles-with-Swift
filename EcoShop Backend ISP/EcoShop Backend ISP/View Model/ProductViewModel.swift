//
//  ProductViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Combine
import Foundation

@MainActor
class ProductListViewModel: ObservableObject {
    private let productReader: ProductReading
    
    @Published var products: [Product] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(productReader: ProductReading) {
        self.productReader = productReader
    }
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedProducts = try await productReader.findAllProducts()
            self.products = loadedProducts
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

@MainActor
class ProductMutationViewModel: ObservableObject {
    private let productWriter: ProductWriting
    
    @Published var errorMessage: String?
    
    init(productWriter: ProductWriting) {
        self.productWriter = productWriter
    }
    
    func addProduct(_ product: Product) async {
        errorMessage = nil
        
        do {
            try await productWriter.addProduct(product)
        } catch {
            errorMessage = "Failed to add product: \(error.localizedDescription)"
        }
    }
    
    func deleteProduct(_ productId: String) async {
        errorMessage = nil
        
        do {
            try await productWriter.deleteProduct(productId)
        } catch {
            errorMessage = "Failed to delete product: \(error.localizedDescription)"
        }
    }
}
