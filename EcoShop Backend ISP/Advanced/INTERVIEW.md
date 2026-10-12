# Interview practice · Independent consumers, shared state

[Back to the lab](README.md) · [Learning progression](../../docs/LEARNING_PATH.md)

Answer with a consumer, a change pressure and supporting evidence. Read the notes after attempting these questions.

1. Why does a history-only screen create a reason to split the broader order API?
2. What would make one protocol per CRUD method excessive here?
3. Why can one concrete actor implement several capabilities without violating ISP?
4. How do submission-only and reader-only fixtures provide compile-time evidence?
5. Why should write confirmation not require a history query?
6. A write succeeds while history is offline. What should each screen say, and what should happen on recovery?
7. Does interface segregation imply separate databases or independent infrastructure availability?
8. How do you keep an old history response from replacing a newer snapshot?
9. A submission was cancelled before acknowledgement. Can you promise it did not commit? How should retry work?
10. What must an idempotency policy define beyond choosing a UUID?
11. Why should an identity conflict be distinguished from a transient failure?
12. Product introduces cancellation. How can narrow consumers remain independent while history gains a new status?
13. Can broad shared data models reintroduce coupling after methods are segregated?
14. Why is a reader interface not an authorization boundary? Where would trusted enforcement belong in a real system?
15. Your teammate proposes several new tiny protocols. How would you evaluate them together and migrate existing consumers safely?

## Self-review

A useful answer identifies actual consumer needs, distinguishes dependency shape from behaviour and security, names snapshot/acknowledgement owners, defines failure and retry semantics, considers a simpler option, and explains how to evolve the API with evidence.

This is a study aid, not a hiring score. Relate the discussion to work you have owned and incidents you have handled.

[Compare with the answer notes](INTERVIEW_NOTES.md).
