# Interview answer notes

[Questions](INTERVIEW.md) · [Back to the lab](README.md)

These are discussion anchors. Alternative designs can be valid when their consumers, contracts and constraints are explicit.

1. A history consumer has no reason to acquire placement/update/cancellation operations. An entry consumer can confirm from a receipt without list operations. Identify those clients before splitting the interface.
2. Group by cohesive need and independent change. Several history queries could belong together if the same consumer needs them; method count is not the objective.
3. Implementation topology and consumer dependency shape are different. A shared store can supply several views of its API while preserving one source of records.
4. The fixtures do not implement the unwanted operations. If the real model asks for a broader interface, compilation fails rather than letting a stub hide the dependency.
5. Submission returns its own acknowledgement. Requiring a query introduces unnecessary availability/consistency assumptions and can misrepresent a successful write as a refresh failure.
6. Entry shows confirmed; history marks its retained snapshot and refresh failure. Restoring reads fetches the current book. This lab uses explicit refresh, not automatic subscriptions.
7. No. The independent fault ports illustrate endpoint-like failures while storage stays healthy. A shared database outage could affect both, and replication would need explicit consistency rules.
8. Establish load identity synchronously, cancel older interest, and check identity after suspension. Cancellation alone does not stop a noncooperative reader from returning late.
9. Commit may precede cancellation or a lost response. Keep the immutable request identity/payload and retry through an idempotent contract; do not invent a new ID merely because the response was not observed.
10. Define identity namespace, payload matching, retention, concurrency, durable uniqueness, acknowledgement replay and conflict handling. This lab guarantees only session-local protection.
11. A permanent payload conflict will not become safe through repeated retries. Classify it as a domain failure instead of claiming the service is offline.
12. Add a cancellation workflow only when the new consumer justifies it. Keep original submission acknowledgements immutable and evolve the history projection independently.
13. Yes. Sharing one mutable, expanding domain object can force unrelated consumers to change. Consumer-owned projections and acknowledgement types can reduce that coupling when the requirement appears.
14. Narrow interfaces shape source dependencies. They do not authenticate users, govern server access or prevent a client from constructing other calls. Trusted enforcement belongs at the service boundary, outside this local lab.
15. Map used operations, ask which requirement each proposed interface serves, compare a smaller design, introduce adapters incrementally, and verify actual consumers with narrow fixtures. Discuss evidence and migration costs rather than treating a preferred hierarchy as a rule.
