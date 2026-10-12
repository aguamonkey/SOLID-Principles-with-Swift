# Interview answer notes

[Prompts](INTERVIEW.md) · [Advanced lesson](README.md)

Use these to compare reasoning after answering aloud; they are not scripts or a hiring rubric.

## 1. What is the reason to change each boundary?

Data owners correct facts, editors change prose, integration consumers change schema, and product/design owners change publication or presentation. These roles may be the same person but the decisions remain independent.

## 2. Why is a model with refresh, failure and cancellation still cohesive?

They form one loading/publication policy. Counting methods is not a useful SRP test; ask whether independent stakeholder decisions collide.

## 3. Why move wording out of the domain model here?

A second consumer requires stable machine facts while editors change display prose. The foundation kept wording near small models; this new pressure justifies a separate projector.

## 4. Why validate before either consumer projects?

Unique identity and complete facts are shared invariants. Duplicating validation in both readers risks inconsistent acceptance and unclear ownership.

## 5. Does one shared edition remove all coupling?

No. A domain field change can legitimately affect both projectors. Separate consumer DTOs and policies reduce accidental coupling, not necessary coordination.

## 6. Why do the previews avoid independent fetches?

The product requires two readings of one loaded edition. Separate requests could mix revisions; independent freshness would justify reconsidering the design.

## 7. What proves a wording change leaves export intact?

Compare the encoded bytes and decoded field contract from the same snapshot before/after the editorial choice. Also verify no additional source reads and unchanged identity.

## 8. Why is the export DTO separate from GuideFigure?

External field names and schema versions belong to the integration contract. Synthesising Codable on the domain model would make internal refactors alter that contract more easily.

## 9. Is sorted JSON a canonical format?

No. Sorted keys and UUID order help local comparisons. Cross-platform signatures require a specified canonical encoding; this implementation does not promise one.

## 10. What should happen when refresh fails?

Keep the actual loaded revision and facts for both consumers, show a warning, and distinguish first failure from an empty successful edition. Requested revision is not loaded revision.

## 11. What prevents an older request from publishing?

A per-request identity plus cancellation checks after awaiting the source. Tests use a source that ignores cancellation; UI cancellation cannot force that work to stop.

## 12. Why not create formatter protocols now?

Concrete pure value types already isolate change and support tests. Add interfaces when runtime replacement, external plugins or another demonstrated constraint needs them.

## 13. How would localisation change this design?

Editorial resources translate display templates and vocabulary. Keep stable IDs and raw export values. Full UI localisation includes controls, errors, pluralisation and accessibility beyond this exercise.

## 14. How would you add file sharing?

Keep serialization with export policy and put file creation/lifetime and sharing in appropriate platform infrastructure/presentation boundaries. Decide cleanup, failures and revision provenance before implementing it.

## 15. How would you introduce these boundaries into a shipping app?

Capture outputs, extract without behaviour changes, validate representative data, define consumer freshness, compare contracts and use an explicit rollout/rollback. Do not turn every noun into a service.
