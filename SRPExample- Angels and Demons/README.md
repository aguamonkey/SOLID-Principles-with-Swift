# 01 · Single Responsibility

[All lessons](../README.md) · [Setup and test commands](../docs/SETUP.md)

A type should have one reason to change. Identify responsibilities by the changes people request, rather than by counting methods or files.

In **Angels and Demons**, data access, hierarchy descriptions, and visual presentation can evolve for different reasons.

## Run the app

Open the [Xcode project](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons.xcodeproj), select the `SRP-Example-Angels-and-Demons` scheme and a compatible iPhone simulator, then press **Cmd+R**. Choose **View Angels** or **View Demons** and open an entry. Data is supplied locally after a simulated delay.

## Before: unrelated changes meet in one place

This illustrative sketch is not an additional app implementation:

```swift
struct AngelScreen: View {
    // Also owns loading, hierarchy rules, and formatting.
    func fetchAngels() async throws -> [AngelModel] { /* ... */ }
    func describeHierarchy(_ angels: [AngelModel]) -> String { /* ... */ }
    var body: some View { /* ... */ }
}
```

A data-source change, a hierarchy wording change, and a layout change all lead back to the same type. The pressure comes from those independent decisions, not simply from the type being long.

## After: give changes a home

| Change request | Primary owner in this example |
| --- | --- |
| Change how sample data is supplied | `DataService` |
| Change the hierarchy description | `AngelHierarchy` / `DevilHierarchy` |
| Change an angel's power description | `AngelModel` |
| Change card layout | `AngelView` |
| Change navigation | `ContentView` and the list/detail views |

This separation is partial: `AngelListView` still starts loading and constructs its hierarchy. Treat moving that orchestration into a view model as a possible next step if the screen acquires more behaviour.

## Read the source

1. [DataService.swift](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons/DataService/DataService.swift): locate data access and the injected protocol.
2. [AngelHierarchy.swift](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons/Angel/AngelHierarchy.swift): inspect the hierarchy description independently of SwiftUI.
3. [AngelModel.swift](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons/Angel/AngelModel.swift): find the power description.
4. [AngelListView.swift](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons/Angel/AngelListView.swift): trace loading and navigation.
5. [AngelView.swift](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-Demons/Angel/AngelView.swift): see how the model is rendered.

## Read and run the tests

Open the [SRP unit tests](SRP-Example-Angels-and-Demons/SRP-Example-Angels-and-DemonsTests/SRP_Example_Angels_and_DemonsTests.swift) and press **Cmd+U**.

- `testHierarchyDescriptionCanChangeWithoutTouchingViewsOrDataService` checks a hierarchy description without constructing either dependency.
- `testModelOwnsAngelPowerDescriptionWithoutNeedingAView` checks domain wording without rendering a screen.

These assertions demonstrate independently callable behaviour; they do not prove that every responsibility is perfectly separated.

## Exercise

Change the hierarchy description to include the member names, for example: `Archangel: Michael, Gabriel`.

Before editing, identify the owner. Update the description and its assertion without changing data loading or view layout. As a stretch exercise, consider where this wording should live if it must be localised.

[Compare with the solution](SOLUTION.md).

## Tradeoffs and interview discussion

SRP does not require one method per type. Related operations may share a reason to change. Extract a view model when orchestration needs independent testing or becomes difficult to follow; creating one purely to forward a single value can add navigation overhead.

Discuss: **If the hierarchy rank became server-controlled, which responsibility would move, and which code would remain unchanged?**

## Continue learning

[02 · Open/Closed →](../Open-Closed-Principle-%28OCP%29-Galactic-Explorer/README.md)
