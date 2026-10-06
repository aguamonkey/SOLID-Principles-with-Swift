import Foundation

/// Concrete choices live at the outer boundary, never inside the receiver model.
enum DemoSource: String, CaseIterable, Identifiable {
    case sample = "Sample"
    case delayed = "Delayed"
    case disconnected = "Offline"
    var id: String { rawValue }
    var index: Int { Self.allCases.firstIndex(of: self)! }
    var detail: String {
        switch self {
        case .sample: return "Fixed bytes / instant delivery"
        case .delayed: return "Same bytes / three-second delay"
        case .disconnected: return "Simulated failure / no connection"
        }
    }
}

enum NetworkComposition {
    // A descriptive URL passed through the contract. Offline adapters ignore it.
    static let demoURL = URL(string: "https://example.com/signal")!

    static func repository(for source: DemoSource, logger: LoggingServiceProtocol) -> NetworkRepositoryProtocol {
        let service: NetworkServiceProtocol
        switch source {
        case .sample: service = SampleNetworkService()
        case .delayed: service = DelayedNetworkService()
        case .disconnected: service = DisconnectedNetworkService()
        }
        let useCase = FetchDataUseCase(networkService: service, logger: logger)
        return NetworkRepository(fetchDataUseCase: useCase)
    }
}
