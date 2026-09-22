# Exercise solution: 01 · Single Responsibility

[Back to the lesson](README.md#exercise)

The hierarchy owns this description. In `AngelHierarchy.describeHierarchy()`, use:

```swift
func describeHierarchy() -> String {
    "\(rank): \(angels.map(\.name).joined(separator: ", "))"
}
```

For the existing two-angel fixture, change the expected value to `Archangel: Michael, Gabriel`. Run the SRP unit tests. Data loading and the view layout need no edits for this change.

This is a proposed exercise implementation, not a change already applied to the app. If wording becomes localised, a presentation formatter may become a better owner than the domain type; explain that new change pressure before introducing it.
