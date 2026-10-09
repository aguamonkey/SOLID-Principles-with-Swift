import Foundation

/// Actor isolation protects memory. Request identity protects ordering across await.
actor RefreshingSignalStore: SignalRepository {
    private let transport: any SignalTransport
    private let now: @Sendable () -> Date
    private var cache: [URL: SignalSnapshot]
    private var latestRequests: [URL: UUID] = [:]

    init(transport: any SignalTransport, seed: [URL: SignalSnapshot] = [:],
         now: @escaping @Sendable () -> Date = { Date() }) {
        self.transport = transport
        self.cache = seed
        self.now = now
    }

    func cachedSignal(for url: URL) -> SignalSnapshot? { cache[url] }

    func refreshSignal(for url: URL) async throws -> SignalSnapshot {
        try Task.checkCancellation()
        let requestID = UUID()
        latestRequests[url] = requestID
        defer {
            if latestRequests[url] == requestID { latestRequests[url] = nil }
        }
        let result: Result<Data, Error>
        do {
            result = .success(try await transport.fetchSignal(from: url))
        } catch {
            result = .failure(error)
        }
        // Revalidate both success and failure after the transport suspension.
        // Cancellation takes precedence, then supersession, then transport outcome.
        try Task.checkCancellation()
        guard latestRequests[url] == requestID else { throw SignalRefreshError.superseded }
        let data = try result.get()
        let snapshot = SignalSnapshot(data: data, receivedAt: now())
        cache[url] = snapshot
        return snapshot
    }
}
