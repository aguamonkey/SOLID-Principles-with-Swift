# Interview answer notes

[Questions](INTERVIEW.md) · [Back to the lab](README.md)

These are discussion anchors, not scripts to memorise. A different design can be valid if its contract and constraints are explicit.

1. `ContentViewModel` depends on `NetworkRepositoryProtocol`, and composition supplies an implementation. Injection describes supplying the object; inversion describes the direction of source dependencies.
2. The advanced repository contains cache and ordering policy. A use-case wrapper that only forwards would add navigation cost without adding a decision. Count responsibilities and change pressures, not protocols.
3. Retaining content helps readers during slow/offline refresh, and the session cache supports reopening and shared consumers. A single isolated screen may only need local display state.
4. An actor can process another call while the first is suspended at transport. Trace A-issued → A-await → B-issued → B-commit → A-return. Only a revalidated request identity prevents A from committing. See `testOlderSuccessCannotOverwriteNewerCacheEvenWithoutCancellation`.
5. The store checks cancellation after transport and before its non-suspending commit. Outcome precedence is cancellation, supersession, then transport success/failure; an obsolete transport error is reported as superseded. The main-actor model also gates publication by identity and cancellation. Cancelling after an already completed commit does not roll the cache back.
6. Latest-issued rejects A even if B fails; it keeps the previous cache rather than resurrecting superseded work. Latest-successful could accept A, but must define ordering and version semantics. The lab makes its stricter choice visible in a regression test.
7. Controls might configure adapter B while the retained model still reads adapter A. `RefreshLabSession` retains the entire graph together, and the child screen observes its existing model.
8. Deduplication creates a repository-owned task and multiple waiters. Define whether one waiter cancels its subscription only and whether the last waiter cancels transport. Guard against attaching new waiters to cancelled work. The current per-consumer task contract does not provide this.
9. Namespace entries by account/resource, prevent the previous account's data appearing on screen, invalidate visible work immediately, and reject obsolete commits at the storage boundary. Clearing a dictionary alone may allow a suspended request to refill it.
10. The freshness exercise can live in the screen's opening policy initially. Persistence introduces serialization, migration, bounds, invalidation and failures; HTTP caching introduces server directives and validators. Do not conflate these decisions.
11. Request issue order is local ordering, not server revision ordering. A server version or monotonic domain revision is needed, with a defined comparison rule and conflict handling.
12. Useful dimensions include correlation, duration, outcome categories and cache age. Avoid raw payloads, unrestricted URLs or identifiers. Current fixed lifecycle events avoid those values but cannot correlate independent requests or diagnose latency. State how you would validate privacy and instrumentation.
13. Start with existing tests, agree the changed semantics, introduce one injected path, verify device behaviour, stage release, compare diagnostic/user impact and retain a rollback composition choice. Disk schema changes require more than a UI rollback.
14. Controlled continuations prove order and cancellation invariants. UI tests prove interaction and accessible layout. HTTP status validation, validators, decoding, server revisions, real network cancellation and persistent cache migration need separate adapters and suitable integration evidence.
15. Ask which unmet requirement each addition serves. Agree on evidence such as process-restart behaviour, existing product constraints and responsibility ownership. Compare a small prototype or decision note, make the tradeoffs visible, and agree a reversible next step rather than treating a preferred architecture as a personal position.

A useful follow-up is: **Which assumption in your answer would you confirm before implementation, and how would its answer change the design?**
