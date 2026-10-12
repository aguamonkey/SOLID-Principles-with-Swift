# Exercise · Add a cancellation desk without widening entry

[Back to the lab](README.md) · [Interview prompts](INTERVIEW.md)

A separate desk must mark an already recorded order as cancelled. It is a manual ledger annotation, not a payment refund. Order entry should still depend only on submission, and history should still depend only on reading.

## Decide before coding

1. What does the new consumer need, and what does it not need?
2. Does it need a new `OrderCancelling` capability, or does an existing consumer already own this operation?
3. How will history show cancellation without mutating the original submission acknowledgement?
4. What does retrying a cancellation mean? What happens for an unknown ID?
5. Why is receiving a cancelling interface different from being authorized to cancel?

## Acceptance criteria

- Give the cancellation consumer an interface shaped around its workflow, without submission or history methods.
- Keep the entry model and its submission-only fixture unchanged.
- The same concrete store handles the new capability; do not create a second copy of order data.
- Repeated cancellation returns a defined, stable acknowledgement and does not duplicate annotations.
- Unknown order IDs produce an explicit domain failure.
- A history reload shows the updated status, while replaying the original submission still returns its original acknowledgement.
- Keep successful writes independent of read-refresh failure and preserve cancellation/ordering tests.
- Update the decision record, source route and UI. No payment operation or authorization system is implied.

## Deliverables

Write a decision note, implement the capability and consumer, and test a cancellation-only fixture, repeat/unknown IDs, history refresh failure, and original submission replay after cancellation.

Cancellation annotations are **not implemented in the baseline lab**. Save your attempt on a descriptive practice branch before reading the [separate solution](SOLUTION.md).
