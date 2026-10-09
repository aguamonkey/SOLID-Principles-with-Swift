# Decision · Retain content and gate cache commits

[Back to the lab](README.md)

**Status:** implemented in the advanced lab. This record explains a decision for these constraints, not a universal networking architecture.

## Context

A read-only bulletin must remain usable during refresh failure. Concurrent consumers may refresh the same URL. Transport can ignore cancellation and return late. The original patchboard intentionally clears its payload when reconnecting and creates a new graph on source selection; changing those semantics would obscure its smaller lesson.

## Decision

Introduce a separate refresh screen with a consumer-owned `SignalRepository` contract. Its actor implementation retains snapshots by URL for the lifetime of a composition session. Each refresh receives a per-URL identity before transport starts; after the transport suspension, only that identity may commit. A newer failed refresh still invalidates older requests. After suspension, cancellation takes precedence over supersession, and supersession takes precedence over the transport outcome, including a late failure.

The main-actor view model separately guards publication by screen request identity. It retains saved content when refreshing or failing, supplies a generic user-facing warning, and records lifecycle events through an injected reporter. The cache and screen enforce different invariants; neither relies solely on the other.

The composition session retains the model and its concrete demo adapter together. The model owns its refresh task; leaving the tab cancels that task. The repository does not own a detached background worker. A second consumer has its own task and may continue independently.

## Alternatives considered

| Alternative | Useful when | Why it was not selected here |
| --- | --- | --- |
| Keep only the last displayed payload in the view model | One screen, no shared consumer or reopen requirement | It cannot establish a shared cache invariant |
| Inject a disk cache immediately | Saved content must survive process termination | Persistence, schema migration, eviction, and account scope are outside this scenario |
| Actor cache with no request identity | No suspension between validation and mutation | Transport suspends; actor reentrancy permits newer work to run |
| Cancel older work and trust the adapter | Every adapter cooperates, and results have no shared side effects | Cancellation is cooperative; a late adapter response still needs a commit guard |
| Coalesce concurrent callers into one transport task | Duplicate traffic matters and callers share compatible policies | It changes who owns cancellation and requires explicit waiter accounting |
| Add repository, use case, cache, coordinator and factory protocols | Each layer carries independently varying policy | Only the repository and transport boundaries are justified by this exercise |

## Consequences and limits

The cache has no expiry or eviction and uses a URL as its key. It is scoped to one demo session, with tiny local payloads. A production account-aware cache would need an identity namespace, bounded retention, explicit invalidation and a policy for sensitive content. A receipt timestamp describes local arrival; it cannot detect a server returning an older version.

Latest-issued permission is intentionally strict. If consumer B fails, consumer A's earlier successful request is rejected. This avoids resurrecting obsolete work, but sacrifices a potentially useful update. If the product needs a different rule, define it using server revisions or shared in-flight requests and change the tests alongside the contract.

A superseded consumer receives an explicit error and keeps its saved content. There is no automatic stream of another consumer's accepted update; it can revalidate. The exercise does not claim cross-screen synchronization.

Lifecycle logs identify started, cached, succeeded, failed, cancelled and superseded transitions without exposing payloads or URLs. They are an initial diagnostic seam, not complete operational monitoring. Cross-request correlation, durations, failure categories, aggregate rates and retention policies would be further decisions. Logging a raw error can expose a URL or user data, so the reporter accepts only known event names.

## Introduce this into an existing app

1. Capture existing behaviour in tests, especially whether reconnect clears content.
2. Agree on the retained-content and newest-request contracts with the product team. Define whether superseded work should be retried, ignored, or surfaced.
3. Add the consumer-owned contract and an adapter around the existing transport. Keep current screens on their existing path.
4. Introduce the refresh behaviour on one screen with an injected graph and deterministic cache/ordering tests. In this repo the second tab provides that comparison without replacing the patchboard.
5. Verify accessible layouts, cancellation on navigation, and memory growth. Before a real release, add production transport tests and privacy-reviewed diagnostics, then stage the change behind the product's release mechanism.
6. Compare refresh failures and user-visible regressions against the previous behaviour. Roll back the screen's composition choice if needed; adding disk persistence would require its own backward-compatible migration.

## Source notes

Swift documents [cooperative cancellation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/) and [actor reentrancy](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md). Apple's [logging privacy documentation](https://developer.apple.com/documentation/os/oslogprivacy) describes how logged values can be classified. The cache ownership and publication rules above are this lesson's design choices.
