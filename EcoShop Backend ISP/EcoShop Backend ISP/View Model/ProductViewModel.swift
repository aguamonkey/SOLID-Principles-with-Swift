//
//  ProductViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

class ProductViewModel: ObservableObject {
    private let productManager: ProductManaging

    @Published var products: [Product] = []

    init(productManager: ProductManaging) {
        self.productManager = productManager
    }

    func loadProducts() async {
        let loadedProducts = await productManager.findAllProducts()
        DispatchQueue.main.async {
            self.products = loadedProducts
        }
    }

    func addProduct(_ product: Product) {
        productManager.addProduct(product)
        Task {
            await loadProducts()
        }
    }

    func deleteProduct(_ productId: String) {
        productManager.deleteProduct(productId)
        Task {
            await loadProducts()
        }
    }


}
