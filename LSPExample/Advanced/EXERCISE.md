# Exercise · Add a declared recoverable failure

[Back to the lab](README.md) · [Interview prompts](INTERVIEW.md)

An external descriptive-voice adapter can fail temporarily. Product wants to distinguish a voice that is unavailable for this rehearsal from one whose service failed and might be retried. The conductor should keep valid responses from other voices. Cancellation must remain cancellation.

The baseline treats thrown errors other than `CancellationError` as violations. Do not silently broaden that promise by throwing arbitrary transport errors.

## Decide before coding

1. Should a recoverable failure be another outcome or a typed thrown error? Which caller assumptions change?
2. Which details belong in a user-visible message? What should remain private diagnostics?
3. Who decides whether to retry, and how do you prevent duplicated side effects?
4. Does a retry repeat the same cue ID, or create a new cue? State the assumption.
5. How will every implementation and consumer be migrated to the new contract?

## Acceptance criteria

- Declare an explicit recoverable-failure category with a nonblank, safe user message.
- Add a supported voice that produces it through the same uniform operation.
- The shared contract checks accept valid failures and reject malformed ones.
- A valid peer's result remains present and ensemble ordering remains stable.
- No new concrete-type checks are added to the conductor or screen policy.
- Cancellation at entry and after suspension, repeated calls, replacement and stale-result tests continue to pass.
- Expected transport failures are mapped at the adapter boundary; cancellation is not accidentally mapped to a recoverable failure.
- Update the report UI and explain the migration. Automatic retries are outside this exercise.

## Deliverables

Write a short decision note, implement the new outcome and adapter, and add tests for valid failure, blank failure, cancellation precedence and mixed-ensemble ordering. Explain what an automatic retry policy would need to know before it could be added safely.

This outcome is **not implemented in the baseline lab**. Save your attempt on a descriptive practice branch before reading the [separate solution](SOLUTION.md).
