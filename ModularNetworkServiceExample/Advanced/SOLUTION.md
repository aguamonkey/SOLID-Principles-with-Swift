# Solution notes · Freshness belongs to the consumer's opening policy

[Exercise](EXERCISE.md) · [Back to the lab](README.md)

One defensible solution puts this screen-specific opening policy in `RefreshViewModel`. The existing repository already exposes the two necessary operations: read saved content and force an update. If multiple consumers later need the same freshness policy, extract that decision then. The transport should not decide whether this screen accepts saved content.

## Proposed change

Keep `refresh()` as the manual, forced operation. Add an opening operation that first reads the cache, shows it, then refreshes only if the entry is missing or stale. Make the mode explicit in the internal operation rather than inferring it from button labels. The opening task needs the **same synchronous request identity and publication guards** as manual refresh so an old cache read cannot replace newer screen state.

Inject `now: () -> Date` into the main-actor model and accept a freshness interval. A pure predicate is sufficient; it does not need a service protocol:

```swift
// Illustrative addition; this predicate is not part of the baseline app.
func isFresh(_ snapshot: SignalSnapshot, now: Date, interval: TimeInterval) -> Bool {
    let age = now.timeIntervalSince(snapshot.receivedAt)
    return age >= 0 && age < interval
}
```

After cache lookup and the identity/cancellation guard, publish available saved content. If opening automatically and the snapshot is fresh, finish the operation with a distinct saved-content state; do not call transport and do not emit a refresh-success event. Otherwise follow the existing refresh path. Manual refresh skips the freshness shortcut.

Represent “showing fresh saved content” accurately in the UI. The baseline `.ready` state is labelled “UPDATED / SIGNAL SAVED”, which implies a transport result. Add a state such as `.saved` and a label such as “SAVED / RECENT SIGNAL”, and update exhaustive switches. A model-only change that displays the wrong status is incomplete.

The SwiftUI `.task` should call the new opening operation; the button should keep calling forced `refresh()`. The retained composition session supplies the clock. Update source walkthroughs, diagnostic event names and UI tests when their meaning changes.

## Test matrix

| Saved entry | Operation | Expected remote calls | Expected content |
| --- | --- | ---: | --- |
| Age 299 seconds | Automatic open | 0 | Saved entry, correctly labelled |
| Age 300 seconds | Automatic open | 1 | Saved entry while pending; new result on success |
| Future timestamp | Automatic open | 1 | Saved entry while pending |
| None | Automatic open | 1 | Empty/loading state, then result or first-load warning |
| Age 1 second | Manual refresh | 1 | Saved entry while pending; new result on success |
| Stale; transport fails | Automatic open | 1 | Existing entry plus warning |

Use a fixed injected `Date` and a recording repository/transport. Await the opening task for the fresh path and assert the call count is zero. For a pending refresh, await the controlled fixture's arrival before asserting visible content, then explicitly complete it. Add an overlap case in which an older cache read finishes after manual refresh so the publication guard remains tested.

## Discuss the limits

A local receipt time measures how recently this client received bytes. It does not establish the server's version or freshness. HTTP validators such as ETag, cache-control directives, clock changes, account scope and persistent caches need their own contracts. A five-minute duration is a product decision rather than a consequence of DIP.

This is a design guide and acceptance matrix, not a second checked-in implementation. Compare your implementation against behaviour and tradeoffs rather than matching a particular class hierarchy.
