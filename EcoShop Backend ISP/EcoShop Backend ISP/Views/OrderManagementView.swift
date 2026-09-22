import SwiftUI

struct OrderManagementView: View {
    @StateObject private var viewModel: OrderViewModel
    @State private var showingAddOrder = false
    @State private var orderToCancel: Order?

    init(orderProcessor: OrderProcessing) {
        _viewModel = StateObject(wrappedValue: OrderViewModel(orderProcessor: orderProcessor))
    }

    var body: some View {
        LedgerPage(title: "The order\nbook.", subtitle: "From the counter / a record of each purchase.") {
            Button { showingAddOrder = true } label: { Label("Record an order", systemImage: "plus") }
                .buttonStyle(LedgerButtonStyle())
            LedgerStyle.label("PURCHASE RECORDS / GBP")
            if viewModel.isLoading { ProgressView("Opening the order book…") }
            if let error = viewModel.errorMessage {
                LedgerNotice(message: error) { Task { await viewModel.loadOrders() } }
            }
            if !viewModel.isLoading && viewModel.orders.isEmpty && viewModel.errorMessage == nil {
                LedgerNotice(message: "No orders recorded. Add a purchase to begin the book.")
            }
            ForEach(viewModel.orders) { order in
                VStack(alignment: .leading, spacing: 12) {
                    LedgerStyle.label(order.id)
                    Text(order.totalAmount, format: .currency(code: LedgerStyle.currency))
                        .font(.system(.largeTitle, design: .serif))
                    Text(order.orderDate, format: .dateTime.day().month(.wide).year())
                        .foregroundStyle(LedgerStyle.secondary)
                    Text("Goods / \(order.productIds.joined(separator: ", "))")
                        .font(.system(.subheadline, design: .monospaced))
                    Button("Cancel order", role: .destructive) { orderToCancel = order }.buttonStyle(.bordered)
                }
                LedgerStyle.divider
            }
            LedgerNotice(message: "A manual sample order book. No payment is taken.")
        }
        .task { await viewModel.loadOrders() }
        .sheet(isPresented: $showingAddOrder) { AddOrderView(viewModel: viewModel) }
        .confirmationDialog("Cancel this order?", isPresented: Binding(
            get: { orderToCancel != nil }, set: { if !$0 { orderToCancel = nil } }
        ), titleVisibility: .visible) {
            if let order = orderToCancel {
                Button("Cancel order", role: .destructive) { Task { await viewModel.cancelOrder(order.id) } }
            }
        }
    }
}

struct AddOrderView: View {
    @ObservedObject var viewModel: OrderViewModel
    @State private var productIds = ""
    @State private var totalAmount = ""
    @State private var validationError: String?
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Purchase details") {
                    TextField("Product references, e.g. EC-01, EC-03", text: $productIds)
                    TextField("Total in GBP", text: $totalAmount).keyboardType(.decimalPad)
                    Text("Enter references from the Goods register. This sample records them without checking the catalog.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if let error = validationError ?? viewModel.errorMessage { Text(error).foregroundStyle(LedgerStyle.accent) }
                Button(isSaving ? "Recording…" : "Record order") { Task { await save() } }.disabled(isSaving)
            }
            .scrollContentBackground(.hidden).background(LedgerStyle.paper)
            .navigationTitle("New order").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(isSaving) } }
        }.tint(LedgerStyle.ink).interactiveDismissDisabled(isSaving)
    }

    private func save() async {
        validationError = nil
        let ids = productIds.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard !ids.isEmpty, let total = Double(totalAmount.replacingOccurrences(of: ",", with: ".")), total.isFinite, total >= 0 else {
            validationError = "Enter at least one product reference and a valid total of zero or more."
            return
        }
        isSaving = true
        defer { isSaving = false }
        if await viewModel.placeOrder(Order(id: UUID().uuidString, productIds: ids, orderDate: Date(), totalAmount: total)) { dismiss() }
    }
}
