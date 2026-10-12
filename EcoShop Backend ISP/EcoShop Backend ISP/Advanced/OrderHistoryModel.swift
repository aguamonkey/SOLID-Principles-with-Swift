import Combine
import Foundation

@MainActor
final class OrderHistoryModel: ObservableObject {
    private let reader: any OrderHistoryReading
    private var task: Task<Void, Never>?
    private var activeLoad: UUID?
    @Published private(set) var records: [OrderReceipt] = []
    @Published private(set) var isLoading = false
    @Published private(set) var warning: String?
    @Published private(set) var hasLoaded = false

    init(reader: any OrderHistoryReading) { self.reader = reader }

    @discardableResult
    func load() -> Task<Void, Never> {
        task?.cancel()
        let id = UUID()
        activeLoad = id
        isLoading = true
        warning = nil
        let next = Task {
            defer {
                if activeLoad == id { activeLoad = nil; task = nil; isLoading = false }
            }
            do {
                try Task.checkCancellation()
                let received = try await reader.history()
                guard activeLoad == id, !Task.isCancelled else { return }
                records = received
                hasLoaded = true
            } catch {
                guard activeLoad == id, !Task.isCancelled, !(error is CancellationError) else { return }
                warning = hasLoaded ? "History could not be refreshed. Previously loaded records are still shown." : "History could not be refreshed. No records have been loaded yet."
            }
        }
        task = next
        return next
    }

    func cancel() {
        task?.cancel()
        task = nil
        activeLoad = nil
        isLoading = false
    }
}
