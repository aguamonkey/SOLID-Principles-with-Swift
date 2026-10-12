# Decision · Explicit async outcomes and uniform caller checks

[Back to the lab](README.md)

**Status:** implemented. The behaviour below belongs to this teaching abstraction, not every possible audio or async API.

## Context

The synchronous score expects useful text from every selected voice. Introducing asynchronous work raises new questions: whether unavailability is permitted, what cancellation means, whether completion order affects display order, and whether an older cue may publish after a replacement.

We need to distinguish behavioural substitution from injection and from general concurrency correctness. A protocol signature alone cannot express all of the caller's assumptions.

## Decision

Keep the original `Playable` and score intact. Add a distinct `AsyncVoice: Sendable` contract with successful receipts and declared unavailable outcomes. A supported conformer checks cancellation at entry and after suspension and throws only `CancellationError`; preparation failures and other unmodelled errors violate this particular contract.

The conductor invokes every voice uniformly through a task group, records per-voice results, and restores ensemble order after concurrent completions. Unavailability and a contained malformed result do not discard other voices. Shared value checks validate receipt identity and useful descriptions. The model separately protects which cue may publish to the screen.

The marked wrong-cue adapter is deliberately invalid and selectable only as a learning scenario. Reporting its violation does not turn it into a valid substitute. Adding a new supported voice requires the shared behavioural checks, not a new conductor branch.

## Alternatives

| Option | When it is useful | Choice here |
| --- | --- | --- |
| Add `async throws` to the old protocol | Every existing consumer is ready for an intentional API migration | Keep existing assumptions visible through a separate tab and protocol |
| Fail the entire ensemble on any unavailable voice | Product requires an all-or-nothing concert | Keep per-voice outcomes; one unavailable voice does not erase useful responses |
| Sequential performance | Ordering of side effects matters or parallelism adds no value | Concurrent work with deterministic report ordering demonstrates the difference between completion and display order |
| Switch on concrete instrument types | Composition must choose implementations | Keep the switch in composition; caller logic uses only the contract |
| Trust every returned receipt | All adapters are controlled and invalid results are impossible | Explicit checks make violations observable in the learning tool |
| Hide cancellation as unavailability | The API deliberately treats these as the same user intent | Keep them distinct: cancellation belongs to the caller's task lifecycle |

## Ownership and limits

The main-actor model owns one unstructured screen task. The conductor's task group owns its structured children. Parent cancellation propagates to those children; task-group scope still waits for them to finish. The model invalidates cue publication immediately, so the screen can say cancelled while a noncooperative child is still draining. It does not forcibly stop that child or release all resources immediately.

No deadline, retry, real-time synchronisation, rate limit, streaming progress or audio side-effect contract is implemented. The caller publishes a batch after all children finish, not incremental responses. Cancellation that arrives after a terminal outcome was already accepted cannot undo it.

`Sendable` addresses safe transfer between concurrency domains. It does not establish useful results, fair scheduling, cancellation cooperation or freedom from business-level races. The app remains in Swift 5 language mode; this lesson does not claim a whole-project Swift 6 migration.

A receipt violation has a visible category and reason. This is a diagnostic seam rather than production telemetry. An external adapter would need a privacy-reviewed logging policy, correlation and latency evidence. The lab does not log raw errors or play real audio from async voices.

## Migration into a product

1. List existing caller assumptions, including errors and side effects, before changing a protocol.
2. Agree the permitted outcomes and cancellation boundaries with consumers. Decide whether failure is per voice or aggregate.
3. Add an adapter and shared contract checks. Preserve the old synchronous path while evaluating the new consumer.
4. Exercise response ordering, replacement, navigation cancellation and accessibility. Test real adapter behaviour separately from the pure conductor.
5. Introduce the new path gradually with outcome/latency diagnostics and a reversible composition choice. If the adapter cannot honour the contract, change the adapter or negotiate a different abstraction; a type cast does not repair substitutability.

## Reading

Liskov and Wing's [A Behavioral Notion of Subtyping](https://www.cs.cmu.edu/~wing/publications/LiskovWing94.pdf) develops the behavioural expectations behind substitution. Swift's [structured concurrency proposal](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md) explains task ownership and cancellation. The exact outcomes and policies here are decisions for this lab.
