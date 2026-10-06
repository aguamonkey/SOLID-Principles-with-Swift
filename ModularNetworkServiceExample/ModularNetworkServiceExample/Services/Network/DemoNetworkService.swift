import Foundation

/// Offline inputs share the transport contract. None makes an HTTP request.
struct SampleNetworkService: NetworkServiceProtocol {
    static let payload = Data("SIGNAL 05 / RECEIVED\nThe source can change.\nThe receiver keeps its contract.".utf8)
    func fetchData(from url: URL) async throws -> Data { Self.payload }
}

struct DelayedNetworkService: NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> Data {
        try await Task.sleep(nanoseconds: 3_000_000_000)
        return SampleNetworkService.payload
    }
}

struct DisconnectedNetworkService: NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> Data {
        throw DataError.custom("Input disconnected. Select Sample or Delayed to receive a signal.")
    }
}
