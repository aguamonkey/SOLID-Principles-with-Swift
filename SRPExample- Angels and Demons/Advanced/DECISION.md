# Decision · share facts, separate consumer policies

[Advanced lesson](README.md)

## Pressure

One source feeds an editorial guide and a structured export. Changing guide wording must not unexpectedly alter machine fields, and both readers must agree on which validated edition is loaded.

## Decision

Use an immutable `GuideEdition` as the shared value. Validate identity and required facts at construction. Give editorial wording and export schema separate concrete projections. Keep source access and publication in a loading model; views receive the retained edition and render their own projection.

This is a boundary based on independent requests: editors change sentences, integration consumers change schema, data owners change facts, and product owners change refresh behaviour. It is not a rule that each file must have one method. Related operations and data can remain together.

The publication model updates one edition value. It retains that value during refresh and failure, and checks request identity after suspension. This keeps consumers consistent without requiring an actor cache or separate fetching models. Cancellation prevents publication; it cannot forcibly stop an uncooperative source.

## Alternatives

**Put prose and JSON encoding in `GuideFigure`:** small initially, but editorial and external-schema decisions now change the shared domain value. Multiple consumer formats create the pressure to separate them here.

**Give each preview its own source read:** permits independent lifetimes but risks mismatched editions. Both previews are readers of one loaded edition in this product; independent refresh is not required.

**Make the loading model format every output:** centralises work but mixes publication, wording and external schema. Use concrete projectors instead. Add abstraction only when replacement or lifetime requirements justify it.

**A protocol for every projector:** useful for runtime strategy replacement in some apps, but not necessary for two small pure policies. Local value types provide testable independence with less navigation.

**Duplicate consumer-specific data models everywhere:** reduces shared coupling but requires mappings and invariant decisions at every boundary. Here a small common fact model is useful; machine DTOs are kept separate so export changes do not redefine domain storage.

## Migration into an existing app

Capture current wording and export fixtures. Extract projections without changing visible output or field names. Introduce edition validation at the data boundary and agree how existing invalid records should be handled. Move both consumers to one publication point only if shared freshness is a product requirement. Compare old/new output and failures with representative data before switching composition; keep a rollback path. These rollout steps are guidance, not implemented infrastructure.

## Revisit when

Consumers need independent freshness, multiple locales, persistent export files, huge catalogs, or unrelated data ownership. Shared facts remain a coupling point: a domain schema change can legitimately affect both projectors. SRP reduces accidental coupling; it does not eliminate coordinated changes.
