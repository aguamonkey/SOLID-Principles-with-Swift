# Solution notes · Evolve the contract deliberately

[Exercise](EXERCISE.md) · [Back to the lab](README.md)

A defensible choice is to add a declared recoverable-failure value. The conductor already collects independent terminal outcomes rather than failing the batch, so this extends an existing model without introducing arbitrary thrown errors. A typed throwing design could also work, but would require explicitly migrating every catch policy and aggregation rule.

## Proposed changes

Add an outcome such as `.recoverableFailure(message: String)` to `VoiceOutcome` and a corresponding report result. Extend `VoiceContract.violations` to reject a blank message, the conductor's exhaustive mapping to preserve the category, and the view's exhaustive report switch to display it. Update the contract documentation: consumers are now expected to handle a third non-cancellation outcome.

Introduce a consumer-independent adapter that maps expected infrastructure failure into this outcome. Preserve cancellation before mapping errors:

```swift
// Illustrative adapter fragment; not checked into the baseline implementation.
do {
    try Task.checkCancellation()
    let text = try await service.description(for: cue)
    try Task.checkCancellation()
    return .performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id, description: text))
} catch {
    if Task.isCancelled || error is CancellationError { throw CancellationError() }
    guard error is ExpectedServiceFailure else { throw error }
    return .recoverableFailure(message: "This voice could not respond. Try again later.")
}
```

The service and `ExpectedServiceFailure` type are placeholders for the exercise's transport seam and explicitly mapped failures. Unexpected errors remain visible as contract violations instead of being disguised as expected failures. Avoid publishing `error.localizedDescription` indiscriminately: an error may contain a URL or other sensitive context. Map only expected failures; programming errors should not be disguised as routine unavailability. Validate the successful description too, or map malformed external data into an appropriate declared failure.

## Evidence to add

| Case | Expected result |
| --- | --- |
| Recoverable failure with a safe nonblank message | Shared contract accepts it; caller reports the category |
| Blank failure message | Contract violation |
| One valid voice and one failed voice, completing in reverse order | Two reports in ensemble order |
| Cancelled transport throws a different late error | Cancellation stays cancellation |
| Same voice called again after failure | No hidden reset/preparation requirement |
| Old failed cue completes after a newer successful cue | The newer screen report remains unchanged |

Reuse controlled arrivals/completions for ordering tests. Update composition with a selectable failure scenario only after the contract and caller tests work. Add a UI case that distinguishes unavailable, recoverable failure and contract violation.

## Retry is a separate policy

For descriptive local work, repeating may be harmless. A real audio or external-command adapter can produce a side effect before its response is lost. Define idempotency, cue identity, attempt limits, backoff, cancellation and ownership before retrying. A retry-capable interface is not justified merely because one implementation happens to fail.

These are solution notes and an illustrative fragment, not a second runnable implementation. Judge your solution against the contract and evidence rather than matching a class hierarchy.
