# Exercise solution: 05 · Dependency Inversion

[Back to the lesson](README.md#exercise)

Add a private fixture and a test to the existing test target:

```swift
private struct FixedRepository: NetworkRepositoryProtocol {
    let data: Data

    func getData(from url: URL) async throws -> Data {
        data
    }
}
```

Inside the `@MainActor` test class:

```swift
func testViewModelAcceptsFixedRepository() async {
    let expected = Data("SOLID Swift".utf8)
    let viewModel = ContentViewModel(
        networkRepository: FixedRepository(data: expected),
        logger: MockLoggingService()
    )

    await viewModel.loadData(from: URL(string: "https://example.com")!).value

    XCTAssertEqual(viewModel.fetchedData, expected)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isLoading)
}
```

Use `import Foundation`, `import XCTest`, and the existing `@testable import ModularNetworkServiceExample` in the test file. The fixture ignores the URL and performs no network request.

This test isolates the view model's contract with its immediate dependency. The existing tests remain useful for checking the repository/use-case/network chain together. Neither test style requires a container or edits to the view model. Run the DIP unit tests after implementing the exercise.
