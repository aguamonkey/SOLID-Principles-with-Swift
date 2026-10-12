import Combine
import Foundation

@MainActor
final class OrderLabSession: ObservableObject {
    let historyPort: HistoryPort
    let submissionPort: SubmissionPort
    let history: OrderHistoryModel
    let entry: OrderEntryModel

    init() {
        let seed = OrderReceipt(draft: OrderDraft(id: UUID(uuidString: "04000000-0000-0000-0000-000000000001")!, reference: "EC-02", totalPence: 850), recordedAt: Date().addingTimeInterval(-3600))
        let store = OrderBookStore(seed: [seed])
        let reader = HistoryPort(store: store)
        let writer = SubmissionPort(store: store)
        historyPort = reader
        submissionPort = writer
        history = OrderHistoryModel(reader: reader)
        entry = OrderEntryModel(submitter: writer, draft: OrderDraft(id: UUID(), reference: "EC-01", totalPence: 1250))
    }
}
