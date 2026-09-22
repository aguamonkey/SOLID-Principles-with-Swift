# 04 · Interface Segregation

[All lessons](../README.md) · [Setup and test commands](../docs/SETUP.md)

Clients should not be forced to depend on operations they do not use. Shape interfaces around the needs of their consumers.

In **EcoShop**, product, order, and review workflows have separate interfaces. Product access is further split into reading and writing.

## Run the app

Open the [Xcode project](EcoShop%20Backend%20ISP.xcodeproj), select the `EcoShop Backend ISP` scheme and a compatible iPhone simulator, then press **Cmd+R**. Explore the Products, Orders, and Reviews tabs. Despite the folder name, this is a SwiftUI demonstration of service interfaces, not a deployable backend server.

## Before: readers depend on a management API

Illustrative design:

```swift
final class CatalogViewModel {
    private let manager: ProductManaging
    // Only needs findAllProducts(), but its dependency also includes writes.
}
```

A read-only implementation must then supply unrelated write operations, often as empty methods or runtime errors. That friction reveals a mismatch between the consumer and its interface.

## After: depend on the capability needed

The existing protocols separate `ProductReading` from `ProductWriting` and compose them when necessary:

```swift
protocol ProductManaging: ProductReading, ProductWriting {}
```

`ProductListViewModel` accepts a `ProductReading`. `ProductMutationViewModel` accepts a `ProductWriting`. The management screen combines both because it genuinely needs both.

This is distinct from SRP: here the question is what a client must depend on, not only how many responsibilities a concrete service owns.

## Read the source

1. [ProductManaging.swift](EcoShop%20Backend%20ISP/Interfaces/ProductManaging.swift): inspect the read/write contracts and their composition.
2. [ProductViewModel.swift](EcoShop%20Backend%20ISP/View%20Model/ProductViewModel.swift): compare the two consumers' dependencies.
3. [ProductManagementView.swift](EcoShop%20Backend%20ISP/Views/ProductManagementView.swift): see both capabilities assembled in one screen.
4. [ContentView.swift](EcoShop%20Backend%20ISP/Views/ContentView.swift): see the separate product, order, and review workflows.

## Read and run the tests

Open the [ISP unit tests](EcoShop%20Backend%20ISPTests/EcoShop_Backend_ISPTests.swift) and press **Cmd+U**.

- `testProductListViewModelDependsOnlyOnProductReading` supplies a read-only catalog to the real list view model.
- `testProductReadingCanBeUsedWithoutWriteOperations` demonstrates a conformer with no write methods.
- `testProductMutationViewModelDependsOnlyOnProductWriting` verifies adds and deletes through a write-only test double.

Notice the methods these test doubles do **not** need to implement.

## Exercise

Build a catalog-only SwiftUI screen using the existing `ProductListViewModel`, injected with `ProductReading`. Display names and prices without add/delete controls or a `ProductWriting` dependency.

Verify the view model still loads using the existing read-only fixture. Do not introduce a new protocol unless this screen needs a meaningfully different contract.

[Compare with the solution](SOLUTION.md).

## Tradeoffs and interview discussion

Very small protocols can fragment a cohesive API. Reading a product and listing products are grouped here because they form a useful catalog capability. Split further only when an actual consumer or implementation benefits.

Discuss: **Why can one concrete `ProductManager` implement both protocols while a list view model should still accept only one?**

## Continue learning

[← 03 · Liskov Substitution](../LSPExample/README.md) · [05 · Dependency Inversion →](../ModularNetworkServiceExample/README.md)
