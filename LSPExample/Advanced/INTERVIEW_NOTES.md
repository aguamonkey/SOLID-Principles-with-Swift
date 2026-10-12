# Interview answer notes

[Questions](INTERVIEW.md) · [Back to the lab](README.md)

These are discussion anchors, not a script. Other designs can be valid when their contracts and constraints are explicit.

1. Injection supplies a dependency; DIP concerns source-dependency direction; ISP shapes independently needed capabilities. LSP asks whether a supplied conformer preserves its caller's behavioural expectations.
2. No latency deadline or guaranteed availability is promised. A successful receipt must identify the requested cue. Judge against those terms rather than class names or a preference for synchronous execution.
3. No concrete preparation is required; a successful receipt must be usable and correctly identified; identity stays stable. Unique IDs within an ensemble are a collection precondition enforced before work starts.
4. Apply the same repeated-result and cancellation checks to every supported conformer. Deterministic samples expose known violations, but cannot prove every input, side effect, timing, or nontermination case.
5. Safe transfer does not imply useful outputs, a permitted error policy, fairness, idempotency or cancellation cooperation.
6. Children may finish in any order. The caller restores input order explicitly. Choose sequential calls if side effects depend on order or concurrency is unjustified.
7. This product retains each voice's response; unavailability is a value. An all-or-nothing product might cancel peers and reject partial results, but must specify what happens to work already performed.
8. Cancellation signals intent; it does not kill a child. A structured group waits for its children. Racing a timer and then cancelling the loser still cannot guarantee prompt scope exit if that loser never cooperates. See the deadline discussion in the decision record's source reading.
9. The main-actor model invalidates the cue and updates UI immediately. Its older conductor task can remain alive while structured children drain. Guards prevent publication; they do not erase side effects or force resource release.
10. Check task cancellation before converting an error into a user-facing outcome. Expected transport errors belong to the adapter's declared mapping; broad catches can hide bugs and expose unsafe error text.
11. Requiring hidden tuning strengthens the precondition for this contract. A different abstraction could explicitly require a preparation phase, but every caller and conformer must then agree to it.
12. Write the new permitted outcome, update exhaustive consumers and shared tests, adapt external failure at the boundary, and preserve the old path while migrating. The exercise chooses a recoverable-failure value to fit independent aggregation.
13. Decide whether a cue is idempotent, whether repeated IDs duplicate audio, how acknowledgement relates to playback, whether cancellation stops sound and who owns resources. Textual repeatability does not establish audio repeatability.
14. Establish the unmet requirement together. An adapter can translate a compatible implementation; capability segregation can model independently needed operations. A type-specific workaround may conceal that the existing contract is unsuitable. Compare evidence and migration cost rather than defending a favourite hierarchy.
15. Correlate cue/voice/attempt safely, collect duration and outcome categories, and test real adapter semantics. Review privacy, introduce one path gradually, monitor product impact, and retain a reversible composition choice. Do not log unrestricted text or identifiers by default.
