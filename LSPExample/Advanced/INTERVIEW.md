# Interview practice · Async substitution

[Back to the lab](README.md) · [Learning progression](../../docs/LEARNING_PATH.md)

Explain each answer using a caller expectation, a concrete example and relevant evidence. Read the answer notes only after attempting the questions.

1. How does LSP differ from dependency injection, DIP and ISP in these two Orchestra tabs?
2. Why can a delayed or unavailable voice satisfy LSP while a compiling wrong-cue voice violates it?
3. Identify a precondition, postcondition and invariant in the async contract. Which belongs to the ensemble rather than a single conformer?
4. How does the shared test suite help a new conformer? What can it not prove?
5. Why does `Sendable` not establish behavioural substitutability?
6. Why are report order and completion order different decisions? When would you choose sequential calls instead?
7. Should one unavailable voice cancel all the others? Define the product rule before choosing a task-group API.
8. What happens when a child ignores cancellation? Can a timeout implemented as a race in a structured group guarantee prompt return?
9. Explain the difference between “the UI stopped waiting” and “all work and resources stopped”.
10. What should an adapter do with cancellation versus expected infrastructure failure? Why might a broad catch be harmful?
11. If a conformer requires tuning or an audio file before responding, which caller expectation changed?
12. Product introduces recoverable failure. How do you evolve the contract without silently surprising existing consumers?
13. The voice now plays real audio before acknowledging the cue. What new repeatability and side-effect questions arise?
14. Your teammate wants type-specific branches to work around a broken plugin. How would you evaluate an adapter, a capability split or a different contract instead?
15. What diagnostic evidence and migration plan would you require before introducing an external implementation into a shipped app?

## Self-review

A useful explanation states assumptions, distinguishes permitted failure from broken guarantees, names task owners and cancellation boundaries, points to a test, considers a simpler alternative and explains how a changed requirement affects consumers.

This is an interview practice guide, not a job-title score. Connect the reasoning to responsibilities and incidents from your own experience.

[Compare with the answer notes](INTERVIEW_NOTES.md).
