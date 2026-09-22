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

Inside `LSPExampleTests`, add the new production type to the shared contract check:

```swift
func testPercussionHonoursPlayableContract() {
    let drum = PercussionInstrument(id: UUID(), name: "Drum")
    XCTAssertEqual(contractViolations(drum), [])
}
```

The existing private `TestPercussion` fixture already demonstrates substitution; this new assertion checks your production implementation. The helper checks repeated calls, stable identity/name, and useful descriptions.

For the stretch exercise, use a test-only class with a mutable `id` that assigns a new UUID inside `play()`. Its result can be a valid description while the helper still reports `changed identity`. This demonstrates that checking only the returned string is insufficient.

The service needs no edit. The percussion instrument fulfils the performance expectation and advertises no unsupported capability. Run the LSP unit tests; exposing percussion in the selection UI is a separate extension to the exercise.
