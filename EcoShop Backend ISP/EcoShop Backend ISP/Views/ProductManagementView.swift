//
//  ProductManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//


import SwiftUI

struct ProductManagementView: View {
    // INTERFACE SEGREGATION: This view only needs ProductViewModel
    // It doesn't need to know about orders or reviews
    @StateObject private var viewModel: ProductViewModel
    @State private var productName: String = ""
    @State private var productDescription: String = ""
    @State private var productPrice: String = ""
    @State private var showingAlert: Bool = false
    
    init(productManager: ProductManaging) {
        _viewModel = StateObject(wrappedValue: ProductViewModel(productManager: productManager))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
                
                productList
                productInputSection
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Product Management")
            .alert("Invalid Price", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            }
            .task {
                await viewModel.loadProducts()
            }
        }
    }
    
    private var productList: some View {
        List {
            ForEach(viewModel.products, id: \.id) { product in
                VStack(alignment: .leading) {
                    Text(product.name).font(.headline)
                    Text(product.description)
                    Text("Price: $\(product.price, specifier: "%.2f")")
                }
            }
            .onDelete(perform: deleteProduct)
        }
    }
    
    private var productInputSection: some View {
        VStack {
            TextField("Product Name", text: $productName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Description", text: $productDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Price", text: $productPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            Button("Add Product") {
                Task {
                    await addNewProduct()
                }
            }
            .padding()
            .disabled(productName.isEmpty || productDescription.isEmpty || productPrice.isEmpty)
        }
        .padding()
    }
    
    private func addNewProduct() async {
        guard let price = Double(productPrice), price >= 0 else {
            showingAlert = true
            return
        }
        
        let newProduct = Product(
            id: UUID().uuidString,
            name: productName,
            description: productDescription,
            price: price
        )
        
        await viewModel.addProduct(newProduct)
        
        // Clear the input fields
        productName = ""
        productDescription = ""
        productPrice = ""
    }
    
    private func deleteProduct(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let productId = viewModel.products[index].id
                await viewModel.deleteProduct(productId)
            }
        }
    }
}

#Preview {
    ProductManagementView(productManager: MockProductManager())
}
