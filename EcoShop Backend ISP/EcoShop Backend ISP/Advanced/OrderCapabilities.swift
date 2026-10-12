import Foundation

struct OrderDraft: Equatable, Sendable {
    let id: UUID
    let reference: String
    let totalPence: Int
}

struct OrderReceipt: Identifiable, Equatable, Sendable {
    let draft: OrderDraft
    let recordedAt: Date
    var id: UUID { draft.id }
    var amount: Decimal { Decimal(draft.totalPence) / 100 }
}

/// Cohesive history workflow. No submission, mutation or catalog dependency.
protocol OrderHistoryReading: Sendable {
    func history() async throws -> [OrderReceipt]
}

/// Submission returns its own acknowledgement; the caller need not query history.
/// Repeating the same ID/payload returns the same receipt in this session.
protocol OrderSubmitting: Sendable {
    func submit(_ draft: OrderDraft) async throws -> OrderReceipt
}

enum OrderBookError: Error { case invalidDraft, conflictingIdentity, offline }
