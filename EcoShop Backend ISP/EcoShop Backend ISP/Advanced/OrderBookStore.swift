import Foundation

/// One actor implements both capabilities; consumer independence does not require two databases.
actor OrderBookStore: OrderHistoryReading, OrderSubmitting {
    private var receipts: [OrderReceipt]
    private let now: @Sendable () -> Date

    init(seed: [OrderReceipt] = [], now: @escaping @Sendable () -> Date = { Date() }) {
        self.receipts = seed
        self.now = now
    }

    func history() throws -> [OrderReceipt] {
        try Task.checkCancellation()
        return Array(receipts.reversed())
    }

    func submit(_ draft: OrderDraft) throws -> OrderReceipt {
        try Task.checkCancellation()
        guard !draft.reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, draft.totalPence >= 0 else {
            throw OrderBookError.invalidDraft
        }
        if let existing = receipts.first(where: { $0.id == draft.id }) {
            guard existing.draft == draft else { throw OrderBookError.conflictingIdentity }
            return existing
        }
        // No suspension between checking identity and committing the receipt.
        let receipt = OrderReceipt(draft: draft, recordedAt: now())
        receipts.append(receipt)
        return receipt
    }
}

/// Demo faults are configured at composition; neither consumer gets fault-control methods.
actor HistoryPort: OrderHistoryReading {
    private let store: OrderBookStore
    private var offline = false
    init(store: OrderBookStore) { self.store = store }
    func setOffline(_ value: Bool) { offline = value }
    func history() async throws -> [OrderReceipt] {
        try Task.checkCancellation()
        if offline { throw OrderBookError.offline }
        return try await store.history()
    }
}

actor SubmissionPort: OrderSubmitting {
    private let store: OrderBookStore
    private var offline = false
    init(store: OrderBookStore) { self.store = store }
    func setOffline(_ value: Bool) { offline = value }
    func submit(_ draft: OrderDraft) async throws -> OrderReceipt {
        let unavailable = offline
        try await Task.sleep(nanoseconds: 350_000_000)
        try Task.checkCancellation()
        if unavailable { throw OrderBookError.offline }
        return try await store.submit(draft)
    }
}
