//
//  OrderManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import SwiftUI

struct OrderManagementView: View {
    @StateObject private var viewModel: OrderViewModel
    @State private var showingAddOrderView = false
    
    init(orderProcessor: OrderProcessing) {
        _viewModel = StateObject(wrappedValue: OrderViewModel(orderProcessor: orderProcessor))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
                
                orderList
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Order Management")
            .toolbar {
                Button(action: {
                    showingAddOrderView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddOrderView) {
                AddOrderView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadOrders()
            }
        }
    }
    
    private var orderList: some View {
        List {
            ForEach(viewModel.orders, id: \.id) { order in
                VStack(alignment: .leading) {
                    Text("Order ID: \(order.id)")
                    Text("Total: $\(order.totalAmount, specifier: "%.2f")")
                    Text("Date: \(order.orderDate, formatter: dateFormatter)")
                    Button("Cancel Order") {
                        Task {
                            await viewModel.cancelOrder(order.id)
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

struct AddOrderView: View {
    @ObservedObject var viewModel: OrderViewModel
    @State private var productIds: String = ""
    @State private var totalAmount: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Product IDs (comma-separated)", text: $productIds)
                TextField("Total Amount", text: $totalAmount)
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
            }
            .navigationTitle("New Order")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func placeOrder() async {
        let ids = productIds.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        if let total = Double(totalAmount) {
            let newOrder = Order(
                id: UUID().uuidString,
                productIds: ids,
                orderDate: Date(),
                totalAmount: total
            )
            await viewModel.placeOrder(newOrder)
            dismiss()
        }
    }
}

#Preview {
    OrderManagementView(orderProcessor: MockOrderProcessor())
}
