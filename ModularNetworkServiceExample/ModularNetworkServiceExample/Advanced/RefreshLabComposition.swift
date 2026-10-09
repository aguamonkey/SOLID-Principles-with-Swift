import Combine
import Foundation

/// Concrete laboratory controls stay in composition, outside the screen's policy.
actor DemoRefreshTransport: SignalTransport {
    enum Input: Sendable { case updated, offline }
    private var input: Input = .updated
    private var revision = 0
    private let delayNanoseconds: UInt64

    init(delayNanoseconds: UInt64 = 3_000_000_000) {
        self.delayNanoseconds = delayNanoseconds
    }

    func select(_ input: Input) throws {
        try Task.checkCancellation()
        self.input = input
    }

    func fetchSignal(from url: URL) async throws -> Data {
        let selectedInput = input
        revision += 1
        let issuedRevision = revision
        try await Task.sleep(nanoseconds: delayNanoseconds)
        switch selectedInput {
        case .updated:
            return Data("BULLETIN / REVISION \(issuedRevision)\nFresh signal received.\nSaved content stayed readable during refresh.".utf8)
        case .offline:
            throw URLError(.notConnectedToInternet)
        }
    }
}

@MainActor
enum RefreshLabComposition {
    static let url = URL(string: "https://example.com/bulletin")!
    static func model(transport: DemoRefreshTransport) -> RefreshViewModel {
        let saved = SignalSnapshot(data: Data("BULLETIN / SAVED EDITION\nYour last signal is still here.\nRefresh without losing your place.".utf8),
                                   receivedAt: Date().addingTimeInterval(-3600))
        let store = RefreshingSignalStore(transport: transport, seed: [url: saved])
        return RefreshViewModel(repository: store, reporter: SystemRefreshReporter(), url: url)
    }
}

/// SwiftUI retains the whole graph together, not just the model inside it.
@MainActor
final class RefreshLabSession: ObservableObject {
    let transport: DemoRefreshTransport
    let model: RefreshViewModel

    init() {
        // UI fixtures can keep a pending refresh observable on slower simulators.
        let slowFixture = ProcessInfo.processInfo.environment["REFRESH_LAB_SLOW_INPUT"] == "1"
        let transport = DemoRefreshTransport(delayNanoseconds: slowFixture ? 8_000_000_000 : 3_000_000_000)
        self.transport = transport
        self.model = RefreshLabComposition.model(transport: transport)
    }
}
