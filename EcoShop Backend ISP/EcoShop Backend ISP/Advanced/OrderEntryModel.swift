import Combine
import Foundation

@MainActor
final class OrderEntryModel: ObservableObject {
    private let submitter: any OrderSubmitting
    private var task: Task<Bool, Never>?
    private var activeAttempt: UUID?
    @Published private(set) var draft: OrderDraft
    @Published private(set) var receipt: OrderReceipt?
    @Published private(set) var isSubmitting = false
    @Published private(set) var message: String?

    init(submitter: any OrderSubmitting, draft: OrderDraft) {
        self.submitter = submitter
        self.draft = draft
    }

    @discardableResult
    func submit() -> Task<Bool, Never> {
        if let task { return task }
        if receipt != nil { return Task { true } }
        guard !draft.reference.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, draft.totalPence >= 0 else {
            message = "Enter a product reference and a nonnegative GBP total."
            return Task { false }
        }
        let attempt = UUID()
        activeAttempt = attempt
        isSubmitting = true
        message = nil
        let submitted = draft
        let next = Task {
            defer {
                if activeAttempt == attempt { activeAttempt = nil; task = nil; isSubmitting = false }
            }
            do {
                try Task.checkCancellation()
                let confirmed = try await submitter.submit(submitted)
                guard activeAttempt == attempt, !Task.isCancelled else { return false }
                guard confirmed.draft == submitted else {
                    message = "The receipt does not match this draft. No receipt confirmed."
                    return false
                }
                receipt = confirmed
                return true
            } catch {
                guard activeAttempt == attempt else { return false }
                if Task.isCancelled || error is CancellationError {
                    message = "Recording cancelled. No receipt confirmed; retry the same draft."
                } else if case OrderBookError.conflictingIdentity = error {
                    message = "This draft ID belongs to a different payload. No receipt confirmed."
                } else if case OrderBookError.invalidDraft = error {
                    message = "The draft is invalid. No receipt confirmed."
                } else {
                    message = "Recording failed. No receipt confirmed; retry the same draft."
                }
                return false
            }
        }
        task = next
        return next
    }

    func cancel() {
        guard activeAttempt != nil else { return }
        task?.cancel()
        task = nil
        activeAttempt = nil
        isSubmitting = false
        message = "Recording cancelled. No receipt confirmed; retry the same draft."
    }

    func newDraft() {
        guard !isSubmitting, receipt != nil else { return }
        draft = OrderDraft(id: UUID(), reference: draft.reference, totalPence: draft.totalPence)
        receipt = nil
        message = nil
    }
}
