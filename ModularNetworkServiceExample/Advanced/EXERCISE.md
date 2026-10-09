# Exercise · Define when saved content is too old

[Back to the lab](README.md) · [Interview prompts](INTERVIEW.md)

The bulletin team introduces a requirement: automatic opening should avoid a remote request when saved content is less than five minutes old. A manual refresh must always try the transport. Old content remains readable if refresh fails.

Before editing code, answer:

1. Who owns the five-minute policy: screen, repository, or transport? Why?
2. Is a snapshot exactly five minutes old considered fresh?
3. What happens if the stored timestamp is in the future after a clock correction?
4. How will you test the boundary without sleeping five minutes?
5. Does “fresh locally” mean “latest on the server”?

## Acceptance criteria

- Automatic opening displays a fresh cache entry without calling transport.
- A missing or stale entry triggers refresh while preserving available content.
- A manual refresh always calls transport, even for a fresh entry.
- Failure with stale content retains that content and gives the existing warning.
- Exactly 300 seconds old is stale; a future timestamp is treated as stale.
- Existing request-ordering and cancellation guarantees continue to pass.
- Time-dependent tests use injected time and explicitly controlled transport; no wall-clock sleeps.

Keep the existing repository operations if they remain sufficient. Introduce a new abstraction only when you can explain the independent variation it represents.

## Deliverables

Write a short decision note, implement the policy, and add tests for fresh, boundary, future timestamp, missing cache, forced refresh and failure with stale content. Explain how this local policy differs from HTTP cache headers and from server-provided versions.

The five-minute policy is **not implemented in the running baseline lab**. This is the next change for you to make. Commit your attempt on a descriptive practice branch before comparing with the [separate solution](SOLUTION.md).
