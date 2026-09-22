# 03 · Liskov Substitution

[All lessons](../README.md) · [Setup and test commands](../docs/SETUP.md)

An implementation must honour the behavioural expectations of the abstraction it replaces. Conforming to a Swift protocol checks the required members; it does not prove that the behaviour is suitable for every caller.

In **Orchestra**, `OrchestraService` performs through `Playable` while tuning and blowing are separate capabilities.

## Run the app

Open the [Xcode project](LSPExample.xcodeproj), select the `LSPExample` scheme and a compatible iPhone simulator, then press **Cmd+R**. Use **Select** to add instruments and **Perform** to explore their performance.

## Before: a type accepts the interface but rejects the operation

Illustrative violation, not code to add to the app:

```swift
struct SilentInstrument: Playable {
    let id = UUID()
    func play() -> String {
        fatalError("This instrument cannot play")
    }
}
```

The type compiles as a `Playable`, but an orchestra cannot safely substitute it for an instrument that returns a performance description. A stronger precondition such as “only call this when you know my concrete type” would defeat the caller's abstraction.

## After: preserve the caller's expectations

The current service performs without a concrete-type switch:

```swift
func performConcert() -> [String] {
    instruments.map { $0.play() }
}
```

For this lesson, the intended contract is that every added `Playable` can return a performance description when called, without requiring the orchestra to special-case its type. The existing tests check result counts and instrument names; the protocol itself does not formally document or enforce all of that contract.

`Tunable` and `Blowable` answer a different question: which optional operations does a type support? Separating those capabilities illustrates ISP as well. LSP concerns the behaviour promised by each supported abstraction.

## Read the source

1. [Playable.swift](LSPExample/Protocols/Playable.swift): the common operation.
2. [StringInstrument.swift](LSPExample/Models/StringInstrument.swift): an instrument that plays and tunes.
3. [WindInstrument.swift](LSPExample/Models/WindInstrument.swift): an instrument with an additional blowing capability.
4. [OrchestraService.swift](LSPExample/Services/OrchestraService.swift): compare uniform performance with capability-specific operations.

## Read and run the tests

Open the [LSP unit tests](LSPExampleTests/LSPExampleTests.swift) and press **Cmd+U**.

- `testOrchestraCanPerformWithAnyPlayableInstrument` checks performances from the three existing implementations.
- `testCapabilitySpecificOperationsDoNotBreakPlayableSubstitution` checks that the concert works while tuning and blowing apply to the relevant subsets.

Passing these examples is evidence for those implementations, not a proof about every possible future conformer.

## Exercise

Add a `PercussionInstrument` that conforms only to `Playable`. Add it to an orchestra, check that its performance is returned, and verify it is not included in tuning or blowing results.

Do not change `OrchestraService` to recognise percussion. As a stretch goal, write a shared contract check and apply it to each concrete instrument.

[Compare with the solution](SOLUTION.md).

## Tradeoffs and interview discussion

Separate capabilities when clients need them independently. Avoid forcing every instrument to implement unsupported methods, but do not split a cohesive contract into tiny protocols merely to increase the number of abstractions.

Discuss: **What behaviour could violate LSP even though a type satisfies every Swift protocol requirement?** Consider extra preconditions, weaker results, or unexpected side effects.

## Continue learning

[← 02 · Open/Closed](../Open-Closed-Principle-%28OCP%29-Galactic-Explorer/README.md) · [04 · Interface Segregation →](../EcoShop%20Backend%20ISP/README.md)
