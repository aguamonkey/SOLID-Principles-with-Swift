import XCTest
@testable import ModularNetworkServiceExample

@MainActor
final class ModularNetworkServiceExampleTests: XCTestCase {
    func testSampleCompositionDeliversExactBytes() async {
        let logger = MockLoggingService()
        let model = ContentViewModel(networkRepository: NetworkComposition.repository(for: .sample, logger: logger), logger: logger)
        await model.loadData(from: NetworkComposition.demoURL).value
        XCTAssertEqual(model.fetchedData, SampleNetworkService.payload)
        XCTAssertNil(model.errorMessage)
    }

    func testOfflineCompositionReportsRecoverableFailure() async {
        let logger = MockLoggingService()
        let model = ContentViewModel(networkRepository: NetworkComposition.repository(for: .disconnected, logger: logger), logger: logger)
        await model.loadData(from: NetworkComposition.demoURL).value
        XCTAssertEqual(model.errorMessage, "Input disconnected. Select Sample or Delayed to receive a signal.")
        XCTAssertNil(model.fetchedData)
        XCTAssertFalse(model.isLoading)
    }

    func testDelayedAdapterHonoursCancellation() async {
        let task = Task { try await DelayedNetworkService().fetchData(from: NetworkComposition.demoURL) }
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("A cancelled delivery must not succeed")
        } catch { XCTAssertTrue(error is CancellationError) }
    }
}
