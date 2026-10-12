# Interview answer notes

[Prompts](INTERVIEW.md) · [Advanced lesson](README.md)

These are discussion starting points, not scripts to memorise. Challenge the assumptions and explain what would change your choice.

## 1. Where is this importer closed to modification?

Against another registered type/version: lookup and reporting remain stable. Composition and the new adapter change. New document policies still change the importer.

## 2. When would you replace this registry with a switch?

When the set is deliberately closed and exhaustive compile-time checking matters more than independent registration. Indirection must earn its cost.

## 3. Why dispatch on both type and version?

A familiar type name does not imply familiar units or required fields. Exact keys keep unsupported schemas visible instead of guessing compatibility.

## 4. Why reject duplicate registration?

Silent replacement makes behaviour depend on registration order. Fail composition before importing data; aliases and replacement need an explicit policy.

## 5. Why does the lab compose a new registry when toggled?

Registration is setup work. Immutable snapshots have no read/write races and do not need live-update coordination.

## 6. Does Sendable prove the extension is correct?

It constrains transfer and captured state, not domain truth, termination or performance. Validation, tests and operational limits still matter.

## 7. How is an unsupported record different from a rejected one?

A valid envelope with no exact adapter is unsupported. A bad envelope, known bad payload or invalid extension output is rejected. That distinction directs upgrade versus data-quality work.

## 8. Why can one invalid payload leave other rows readable?

The product treats observations independently. This would be wrong for a transaction requiring all-or-nothing integrity.

## 9. Why does a failed payload still reserve its UUID?

Duplicate selection should not depend on installed extensions. First valid envelope wins identity, which trades recovery of a later valid duplicate for deterministic behaviour.

## 10. Is row index a stable domain ID?

No. It identifies rows within one report, including invalid envelopes. Persistent selection or replay would require a separate validated domain identity and lifecycle.

## 11. What happens if an extension throws or returns empty facts?

The record is rejected with a bounded generic reason. A nonterminating decoder cannot be stopped by this synchronous importer; no timeout guarantee exists.

## 12. Can adding fields break compatibility?

Usually optional unknown fields are ignored here, but changed meaning, units, required fields or producer assumptions can still break compatibility. Test semantic behaviour.

## 13. How would you retain unknown payloads for a later app update?

Add bounded durable storage with provenance and retention policy, then reimport with a new registry. The lab does not retain payloads; its bundled bytes remain available.

## 14. How would you roll this into a production app?

Agree schemas with producers, compare representative fixtures, introduce an explicit composition choice, monitor aggregate outcomes and keep rollback. Decide per consumer whether partial recovery is valid.

## 15. What would make you change the fact projection?

Rich type-specific UI or machine-readable calculations may need a richer domain contract. Plain display facts intentionally trade that flexibility for a uniform report independent of SwiftUI.
