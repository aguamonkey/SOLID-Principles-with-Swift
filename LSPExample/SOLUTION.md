# Exercise solution: 03 · Liskov Substitution

[Back to the lesson](README.md#exercise)

A minimal implementation is:

```swift
struct PercussionInstrument: Playable {
    let id: UUID
    let name: String

    func play() -> String {
        "\(name) plays a steady rhythm."
    }
}
```

Place it in an app source file with `import Foundation` and app target membership. Add this unit test:

```swift
func testPercussionPlaysWithoutOptionalCapabilities() {
    let orchestra = OrchestraService()
    orchestra.addInstrument(PercussionInstrument(id: UUID(), name: "Drum"))

    XCTAssertEqual(orchestra.performConcert(), ["Drum plays a steady rhythm."])
    XCTAssertTrue(orchestra.tuneAll().isEmpty)
    XCTAssertTrue(orchestra.blowAll().isEmpty)
}
```

The service needs no edit. The percussion instrument fulfils the performance expectation and advertises no unsupported capability. Run the LSP unit tests; exposing percussion in the selection UI is a separate extension to the exercise.
