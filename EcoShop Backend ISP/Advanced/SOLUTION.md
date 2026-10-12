# Solution notes · Separate the new workflow and its projection

[Exercise](EXERCISE.md) · [Back to the lab](README.md)

A cancellation-only consumer gives a concrete reason to add a cohesive `OrderCancelling` capability. Adding its methods to `OrderSubmitting` would force an entry-only implementation to acquire unrelated operations. The shared store can implement all three capabilities without exposing all three to every consumer.

## Proposed contract

```swift
// Illustrative addition, not part of the baseline implementation.
protocol OrderCancelling: Sendable {
    func cancelOrder(id: UUID) async throws -> CancellationReceipt
}
```

Define `CancellationReceipt` as a stable acknowledgement identifying the affected order and annotation time. Specify unknown-ID failure and repeated-cancellation behaviour. The cancellation consumer receives a known ID from composition or selection; it should not gain history access just to rediscover one already supplied.

## Separate acknowledgement from history status

The original `OrderReceipt` acknowledges a particular immutable draft. Changing it when the order is cancelled would break submission replay semantics. Keep submission acknowledgements intact and add a history projection such as `OrderHistoryEntry(receipt: OrderReceipt, status: OrderStatus)`.

The store can retain cancellation annotations by order ID and build this projection for readers. The history return type/model/view and their fixtures must migrate deliberately; the submitting contract and entry model need not change. Shared data types are part of dependency design too: narrower methods do not automatically prevent coupling through a broad mutable model.

Keep cancellation lookup and commit within one actor operation without suspension. Repeated calls return the original cancellation receipt. If a remote implementation suspends, revalidate state before committing. Do not assume actor isolation makes a transaction span arbitrary awaits.

## Test matrix

| Case | Evidence |
| --- | --- |
| Cancellation-only fixture | Real cancellation model compiles and works without reads/writes unrelated to its workflow |
| Existing ID cancelled twice | Same acknowledgement, one annotation |
| Unknown ID | Explicit domain failure; no mutation |
| Cancelled order then original submission replay | Original submission acknowledgement remains unchanged |
| History refresh succeeds | Projection reports cancelled status |
| History refresh fails | Cancellation acknowledgement stays confirmed; history marks its old snapshot |
| Consumer task cancelled after commit | No claim that the annotation was undone; retry semantics remain defined |

Document the new read projection and expected UI status. A typed capability still does not enforce authorization; a real service would need its own trusted access checks and durable storage.

These are design notes and an illustrative signature, not a second runnable implementation. Compare your behaviour and tradeoffs rather than copying a class hierarchy.
