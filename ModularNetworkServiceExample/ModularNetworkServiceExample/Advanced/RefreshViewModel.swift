import Combine
import Foundation

@MainActor
final class RefreshViewModel: ObservableObject {
    enum Phase { case idle, refreshing, ready, failed, cancelled, superseded }

    @Published private(set) var snapshot: SignalSnapshot?
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var isCached = false
    @Published private(set) var warning: String?

    private let repository: any SignalRepository
    private let reporter: any RefreshReporting
    private let url: URL
    private var task: Task<Void, Never>?
    private var activeRequest: UUID?

    init(repository: any SignalRepository, reporter: any RefreshReporting, url: URL) {
        self.repository = repository
        self.reporter = reporter
        self.url = url
    }

    @discardableResult
    func refresh() -> Task<Void, Never> {
        task?.cancel()
        let id = UUID()
        activeRequest = id
        phase = .refreshing
        warning = nil
        isCached = snapshot != nil
        reporter.record(.started)
        let next = Task { await performRefresh(id: id) }
        task = next
        return next
    }

    func cancelRefresh() {
        guard activeRequest != nil else { return }
        task?.cancel()
        task = nil
        activeRequest = nil
        phase = .cancelled
        reporter.record(.cancelled)
    }

    private func performRefresh(id: UUID) async {
        defer {
            if activeRequest == id {
                task = nil
                activeRequest = nil
            }
        }
        do {
            try Task.checkCancellation()
            let cached = await repository.cachedSignal(for: url)
            guard activeRequest == id, !Task.isCancelled else { return }
            if let cached {
                snapshot = cached
                isCached = true
                reporter.record(.cacheShown)
            }
            let updated = try await repository.refreshSignal(for: url)
            guard activeRequest == id, !Task.isCancelled else { return }
            snapshot = updated
            isCached = false
            phase = .ready
            reporter.record(.succeeded)
        } catch {
            guard activeRequest == id else { return }
            if Task.isCancelled || error is CancellationError {
                phase = .cancelled
                reporter.record(.cancelled)
            } else if case SignalRefreshError.superseded = error {
                phase = .superseded
                warning = "Another refresh took priority. Refresh again to read its saved result."
                reporter.record(.superseded)
            } else {
                phase = .failed
                warning = snapshot == nil
                    ? "No saved signal is available. Try refreshing again."
                    : "Refresh failed. Your saved signal is still available."
                reporter.record(.failed)
            }
        }
    }
}
