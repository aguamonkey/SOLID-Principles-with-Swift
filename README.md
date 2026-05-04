# SOLID Principles with Swift

Practical Swift and SwiftUI examples for learning the five SOLID design principles through small, runnable Xcode projects.

This repository is built as a guided learning path. Each project focuses on one principle, uses a memorable domain, and keeps the code close enough to real app architecture that the lesson transfers into production Swift code.

## Who This Is For

- Swift developers who know the language basics and want cleaner app architecture.
- iOS developers learning how protocols, view models, services, and dependency injection fit together.
- Interview or portfolio preparation where you want concrete examples of maintainable design.
- Mentors and study groups looking for compact projects to discuss principle by principle.

## Project Map

| Principle | Project | Domain | Start Here | What To Notice |
| --- | --- | --- | --- | --- |
| SRP | `SRPExample- Angels and Demons` | Angels and demons browser | `DataService/DataService.swift` | Data access, hierarchy logic, and SwiftUI views have separate reasons to change. |
| OCP | `Open-Closed-Principle-(OCP)-Galactic-Explorer` | Galactic explorer | `Services/EntityRegistry.swift` | New space entities can be registered in an instance-owned registry without changing the core decoder. |
| LSP | `LSPExample` | Orchestra instruments | `Services/OrchestraService.swift` | The orchestra can perform with any `Playable` instrument through the same abstraction. |
| ISP | `EcoShop Backend ISP` | E-commerce backend views | `Interfaces/ProductManaging.swift` | Product, order, and review workflows depend on focused interfaces instead of one large API. |
| DIP | `ModularNetworkServiceExample` | Network service module | `Services/DIContainer.swift` | High-level view models depend on protocols, while concrete services are supplied at the boundary. |

## Requirements

- Xcode 15 or newer recommended.
- Swift 5.9 or newer recommended.
- iOS Simulator support through the included Xcode projects.

## Getting Started

1. Clone the repository.
2. Open the Xcode project for the principle you want to study.
3. Run the app target to see the example in motion.
4. Open the matching test target to see the principle expressed as assertions.
5. Change or add one concrete type, then confirm the rest of the system does not need to change.

## Learning Path

### How To Read Each Project

For each principle, start with the model or protocol named in the project map, then follow the dependency outward to the service, view model, view, and test. The tests are the fastest way to see the design rule in action: they show what can change without forcing unrelated code to change.

### 1. Single Responsibility Principle

Project: `SRPExample- Angels and Demons`

The SRP example separates SwiftUI navigation, data loading, domain models, and hierarchy description. The core lesson is that a file or type should have one reason to change: UI layout changes should not force data-service edits, and hierarchy-rule changes should not require rewriting views.

Suggested exercise: add a new property to angels or demons and decide which type should own that change.

### 2. Open/Closed Principle

Project: `Open-Closed-Principle-(OCP)-Galactic-Explorer`

The OCP example uses `SpaceEntity`, `EntityRegistry`, and registration functions so new entity types can be introduced through extension points. The decoder remains closed to modification while each app or test can own its own registry.

Suggested exercise: add an `Asteroid` entity and register it without changing the factory's decoding algorithm.

### 3. Liskov Substitution Principle

Project: `LSPExample`

The LSP example models an orchestra that performs with any `Playable`. More specific capabilities, such as `Tunable` and `Blowable`, are handled separately so a general `Playable` can still be substituted safely.

Suggested exercise: add a `PercussionInstrument` that can play but cannot be blown into, then confirm the orchestra still performs correctly.

### 4. Interface Segregation Principle

Project: `EcoShop Backend ISP`

The ISP example separates product, order, and review responsibilities into focused interfaces. It also includes smaller read/write protocol shapes so consumers can depend only on the operations they actually need.

Suggested exercise: introduce a read-only product screen that depends on `ProductReading` instead of full product management.

### 5. Dependency Inversion Principle

Project: `ModularNetworkServiceExample`

The DIP example places protocols between high-level policy and low-level networking/logging details. View models depend on repositories, repositories depend on use cases, and concrete services are registered through the dependency container.

Suggested exercise: swap the real network service for `MockNetworkService` in tests without touching the view model.

## Tests

Each project contains a test target. The most useful tests are the ones that describe the principle directly:

- LSP: any `Playable` can be used by `OrchestraService`.
- OCP: a newly registered entity can be decoded by the existing factory.
- ISP: a consumer can depend on a focused product interface.
- DIP: the network view model can use mock networking and mock logging through protocols.

Run tests from Xcode with `Cmd+U`. From the repository root, these commands build each test bundle into `/tmp` so they work better in sandboxed or local automation environments:

```sh
xcodebuild build-for-testing -project "SRPExample- Angels and Demons/SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons.xcodeproj" -scheme "SRP-Example-Angels-and-Demons" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-srp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "Open-Closed-Principle-(OCP)-Galactic-Explorer/Open-Closed-Principle-(OCP)-Galactic-Explorer.xcodeproj" -scheme "Open-Closed-Principle-(OCP)-Galactic-Explorer" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-ocp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "LSPExample/LSPExample.xcodeproj" -scheme "LSPExample" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-lsp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "EcoShop Backend ISP/EcoShop Backend ISP.xcodeproj" -scheme "EcoShop Backend ISP" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-isp-dd CODE_SIGNING_ALLOWED=NO
xcodebuild build-for-testing -project "ModularNetworkServiceExample/ModularNetworkServiceExample.xcodeproj" -scheme "ModularNetworkServiceExample" -destination "generic/platform=iOS Simulator" -derivedDataPath /tmp/solid-dip-dd CODE_SIGNING_ALLOWED=NO
```

## Repository Goals

This is not intended to be a framework or production app. The goal is to make SOLID visible in Swift code:

- examples should stay small enough to read in one sitting;
- abstractions should exist because they teach a design pressure;
- tests should act as executable documentation;
- comments should explain intent, not repeat the code.

## Contributing

Contributions are welcome when they make a principle clearer, improve build reliability, or add focused tests. Please keep examples compact and avoid unrelated refactors inside principle projects.

Good contributions include:

- adding a before/after example for a principle;
- improving a test so it documents the design rule;
- fixing project naming or setup friction;
- adding screenshots or short demo GIFs.

## License

This project is open source under the MIT License.
