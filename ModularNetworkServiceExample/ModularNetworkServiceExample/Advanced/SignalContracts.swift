import Foundation

/// The consumer needs a snapshot, not knowledge of transport or storage classes.
struct SignalSnapshot: Equatable, Sendable {
    let data: Data
    let receivedAt: Date
}

protocol SignalRepository: Sendable {
    func cachedSignal(for url: URL) async -> SignalSnapshot?
    func refreshSignal(for url: URL) async throws -> SignalSnapshot
}

protocol SignalTransport: Sendable {
    func fetchSignal(from url: URL) async throws -> Data
}

enum SignalRefreshError: Error {
    case superseded
}
