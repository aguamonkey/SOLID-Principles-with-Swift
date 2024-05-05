//
//  ProductManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

//import Foundation
//import SwiftUI
//
//// MARK: - Product Management UI
//
///// A representation of President Interface S. Principle's market square,
///// where each vendor (interface) offers their specialized wares (functions).
//
//struct ProductManagementView: View {
//    @State private var databaseConnector = DatabaseConnector()
//    @State private var products: [Product] = []
//    @State private var productName: String = ""
//    @State private var productDescription: String = ""
//    @State private var productPrice: String = ""
//    @State private var showingAlert = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    ForEach(products, id: \.id) { product in
//                        VStack(alignment: .leading) {
//                            Text(product.name).font(.headline)
//                            Text(product.description)
//                            Text("Price: $\(product.price, specifier: "%.2f")")
//                        }
//                    }
//                    .onDelete(perform: deleteProduct)
//                }
//                
//                // Inputs for adding a new product
//                VStack {
//                    TextField("Product Name", text: $productName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("Description", text: $productDescription)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    TextField("Price", text: $productPrice)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .keyboardType(.decimalPad)
//                    Button("Add Product") {
//                        addNewProduct()
//                    }
//                    .padding()
//                    .disabled(productName.isEmpty || productDescription.isEmpty || productPrice.isEmpty)
//                }
//                .padding()
//            }
//            .navigationTitle("Product Management")
//        }
//        .alert(isPresented: $showingAlert) {
//            Alert(title: Text("Invalid Price"), message: Text("Please enter a valid price."), dismissButton: .default(Text("OK")))
//        }
//    }
//
//    // MARK: - Functions
//    
//    /// Adds a new product to the market, fulfilling a single role as defined by President Principle.
//    private func addNewProduct() {
//        guard let price = Double(productPrice), price >= 0 else {
//            showingAlert = true
//            return
//        }
//        
//        let newProduct = Product(id: UUID().uuidString, name: productName, description: productDescription, price: price)
//        databaseConnector.addItem(newProduct, to: &databaseConnector.products)
//        products.append(newProduct)
//        
//        // Clear the input fields
//        productName = ""
//        productDescription = ""
//        productPrice = ""
//    }
//    
//    /// Deletes a product from the market, demonstrating the removal of a vendor's stall as per the ISP doctrine.
//    private func deleteProduct(at offsets: IndexSet) {
//        for index in offsets {
//            let productId = products[index].id
//            databaseConnector.deleteItem(withId: productId, from: &databaseConnector.products)
//        }
//        products.remove(atOffsets: offsets)
//    }
//}
//
//// MARK: - Product Model Conformance to IdentifiableWithStringID
//
///// Extending our Product model to conform to IdentifiableWithStringID, aligning with the principles of our marketplace.
////extension Product: IdentifiableWithStringID {}
//
//// MARK: - Preview
//
//struct ProductManagementView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductManagementView()
//    }
//}

import SwiftUI

struct ProductManagementView: View {
    @ObservedObject var viewModel: ProductViewModel  // Using ObservableObject ViewModel
    @State private var productName: String = ""
    @State private var productDescription: String = ""
    @State private var productPrice: String = ""
    @State private var showingAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                productList
                productInputSection
            }
            .navigationTitle("Product Management")
            .alert("Invalid Price", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
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
                addNewProduct()
            }
            .padding()
            .disabled(productName.isEmpty || productDescription.isEmpty || productPrice.isEmpty)
        }
        .padding()
    }

    // MARK: - Functions
    
    private func addNewProduct() {
        guard let price = Double(productPrice), price >= 0 else {
            showingAlert = true
            return
        }
        
        let newProduct = Product(id: UUID().uuidString, name: productName, description: productDescription, price: price)
        viewModel.addProduct(newProduct)
        
        // Clear the input fields
        productName = ""
        productDescription = ""
        productPrice = ""
    }
    
    private func deleteProduct(at offsets: IndexSet) {
        offsets.forEach { index in
            let productId = viewModel.products[index].id
            viewModel.deleteProduct(productId)
        }
    }

}

// Assuming Product conforms to Identifiable
struct ProductManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ProductManagementView(viewModel: ProductViewModel(productManager: MockProductManager()))
    }
}

class MockProductManager: ProductManaging {
    func addProduct(_ product: Product) { }
    func updateProduct(_ product: Product) { }
    func deleteProduct(_ productId: String) { }
    func findProduct(byId productId: String) -> Product? { return nil }
    func findAllProducts() -> [Product] { return [] }
}
