# Decision · Acknowledgement does not depend on history refresh

[Back to the lab](README.md)

**Status:** implemented in the separate order capability lab.

## Context

The existing Orders workflow uses a broader `OrderProcessing` interface and reloads its list after submission. A separate entry consumer should not acquire history operations just to discover whether its write succeeded. A history-only consumer should not implement submission or cancellation stubs.

We also need a truthful distinction between acknowledged writes, unknown acknowledgement after cancellation, and stale read-side snapshots.

## Decision

Define `OrderHistoryReading` and `OrderSubmitting` around these consumers. Submission returns an immutable receipt. History owns its loading state and snapshots; entry owns its draft and acknowledgement. Composition owns both consumers and one shared actor store.

History refreshes on entering its desk and through an explicit button. Entry never reloads history. The lab provides two local ports to demonstrate independent endpoint-like failures without duplicating storage. Fault controls belong to composition rather than the consumer interfaces; a completed fault-setting operation does not start an offscreen refresh.

A draft identity is stable until receipt confirmation. Exact equality of ID and payload replays the original acknowledgement; a different payload under the same ID is a permanent conflict. The store checks and commits atomically without suspension. Repeated UI taps share an in-flight task. These reliability choices support the workflows; idempotency and cancellation are not definitions of ISP.

## Alternatives

| Alternative | Useful when | Choice here |
| --- | --- | --- |
| Keep one broad order-management interface | One consumer genuinely needs the complete workflow | Separate entry/history create concrete reasons to narrow dependencies |
| One protocol for every CRUD method | Independently varying consumers actually need each operation separately | Group by cohesive workflows; no quota of interfaces |
| Return no acknowledgement, then query history | Read-after-write consistency and query availability are guaranteed | The consumer's success would depend on an unnecessary capability |
| Separate stores for read and write | A deliberate replicated architecture has consistency rules | Use one store; interface shape does not imply storage topology |
| Refresh history from the entry model | Entry explicitly owns the history presentation too | Composition/history owns refresh; a write outcome stays independent |
| Always invent a new ID on retry | The previous attempt is known never to have committed | Preserve ID/payload when acknowledgement is uncertain |

## Consequences

History can show old data while entry has a confirmed receipt. That is an explicit refresh policy, not an unnoticed consistency bug. An automatic invalidation stream would be a new consumer need and a separate design decision. A shared-storage outage could affect both endpoints in production; the demo faults do not prove operational independence.

Amounts are fixed-currency integer GBP pence, displayed with Decimal. They are manually supplied, not priced from the catalog; no quantities, discounts, tax or settlement are calculated. The study book is separate from the original Orders tab, preserving the before/after comparison.

The store is small and in memory, with linear lookups and no eviction. Duplicate protection ends with the session. A real remote service needs durable, correctly scoped idempotency and an atomic backend constraint. Cancellation can stop interest before receipt confirmation but cannot undo an already committed order. Retry the same payload; do not promise a cancelled write never happened.

Known invalid-draft and identity-conflict errors differ from a transient failure. User messages avoid raw infrastructure error text. The lab has no operational telemetry, persistent storage, catalog validation or authorization.

## Interfaces versus authorization

Receiving a reader limits available methods in that code's dependency. It neither authenticates a user nor enforces who may submit an order. UI controls, casts and client binaries are not a trusted authorization boundary. A real service would enforce access at its trusted boundary; see the [OWASP authorization guidance](https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html). That system is outside this teaching app.

## Migration

1. Map actual consumers and their used operations before splitting a broad API.
2. Introduce narrow contracts and adapters while retaining the old workflow for its existing screen.
3. Return an explicit acknowledgement and agree its retry/identity semantics. Avoid converting read-refresh errors into write errors.
4. Move list refresh ownership to history or composition, and test with submission-only and reading-only fixtures.
5. Add real transport, durable duplicate protection and domain tests before using the pattern for a product. Stage the UI change, measure write outcomes separately from history freshness, and retain a reversible composition choice.

Swift's [protocol documentation](https://docs.swift.org/latest/documentation/the-swift-programming-language/protocols/) describes conformances and composition. Consumer grouping, acknowledgement and refresh policies above are choices for this scenario.
