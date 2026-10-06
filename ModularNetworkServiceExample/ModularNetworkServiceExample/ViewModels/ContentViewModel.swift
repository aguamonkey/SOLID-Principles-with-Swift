import Combine
import Foundation

@MainActor
public final class ContentViewModel: ObservableObject {
    private let networkRepository: NetworkRepositoryProtocol
    private let logger: LoggingServiceProtocol
    private var loadingTask: Task<Void, Never>?
    private var activeLoadID: UUID?

    @Published public private(set) var fetchedData: Data?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isLoading = false
    @Published public private(set) var wasCancelled = false

    public init(networkRepository: NetworkRepositoryProtocol, logger: LoggingServiceProtocol) {
        self.networkRepository = networkRepository
        self.logger = logger
    }

    @discardableResult
    public func loadData(from url: URL) -> Task<Void, Never> {
        loadingTask?.cancel()
        // Establish identity synchronously: even an old task that starts late is stale.
        let loadID = UUID()
        activeLoadID = loadID
        isLoading = true
        wasCancelled = false
        fetchedData = nil
        errorMessage = nil
        let task = Task { await performLoad(from: url, loadID: loadID) }
        loadingTask = task
        return task
    }

    public func cancelLoad() {
        guard isLoading else { return }
        loadingTask?.cancel()
        loadingTask = nil
        activeLoadID = nil
        isLoading = false
        wasCancelled = true
    }

    private func performLoad(from url: URL, loadID: UUID) async {
        defer {
            if activeLoadID == loadID {
                isLoading = false
                loadingTask = nil
                activeLoadID = nil
            }
        }
        do {
            try Task.checkCancellation()
            let data = try await networkRepository.getData(from: url)
            guard !Task.isCancelled, activeLoadID == loadID else { return }
            fetchedData = data
        } catch {
            guard activeLoadID == loadID else { return }
            if Task.isCancelled || error is CancellationError {
                wasCancelled = true
                return
            }
            errorMessage = error.localizedDescription
            logger.log("Error loading data: \(error.localizedDescription)", level: .error)
        }
    }
}
