//
//  OrderManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import SwiftUI

struct OrderManagementView: View {
    @ObservedObject var viewModel: OrderViewModel
    @State private var showingAddOrderView = false  // State to control the display of an add order form

    var body: some View {
        NavigationView {
            VStack {
                orderList
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
                // Assuming AddOrderView exists and is designed to handle the addition of orders
                AddOrderView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
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
                        viewModel.cancelOrder(order.id)
                    }
                    .foregroundColor(.red)
                }
            }
            .onDelete(perform: deleteOrder)
        }
    }

    private func deleteOrder(at offsets: IndexSet) {
        offsets.forEach { index in
            let order = viewModel.orders[index]
            viewModel.cancelOrder(order.id)
        }
    }
}

// DateFormatter for displaying the order date
extension OrderManagementView {
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

// Assuming AddOrderView is defined elsewhere
struct AddOrderView: View {
    @ObservedObject var viewModel: OrderViewModel
    @State private var productIds: String = ""
    @State private var totalAmount: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Product IDs (comma-separated)", text: $productIds)
                TextField("Total Amount", text: $totalAmount)
                Button("Place Order") {
                    placeOrder()
                }
            }
            .navigationTitle("New Order")
            .navigationBarItems(leading: Button("Dismiss") {
                dismiss()
            })
        }
    }

    private func placeOrder() {
        let ids = productIds.split(separator: ",").map { String($0) }
        if let total = Double(totalAmount) {
            let newOrder = Order(id: UUID().uuidString, productIds: ids, orderDate: Date(), totalAmount: total)
            viewModel.placeOrder(newOrder)
        }
        dismiss()
    }

    private func dismiss() {
        // Logic to dismiss this view
    }
}

// Preview for SwiftUI previews
struct OrderManagementView_Previews: PreviewProvider {
    static var previews: some View {
        OrderManagementView(viewModel: OrderViewModel(orderProcessor: MockOrderProcessor()))
    }
}

class MockOrderProcessor: OrderProcessing {
    func findAllOrders() async -> [Order] { return [] }
    func placeOrder(_ order: Order) {}
    func updateOrder(_ order: Order) {}
    func cancelOrder(_ orderId: String) {}
    func getOrder(_ orderId: String) -> Order? { return nil }
}
