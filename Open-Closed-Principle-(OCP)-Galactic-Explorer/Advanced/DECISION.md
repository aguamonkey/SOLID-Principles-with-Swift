# Decision · freeze dispatch, make incompatibility visible

[Advanced lesson](README.md)

## Pressure

Older clients can receive a bulletin containing independently introduced entity types. One bad record should not hide readable observations, and an unrecognised version must not be interpreted using an incompatible decoder.

## Decision

Compose an immutable registry keyed by exact type and positive payload version. Construction throws for duplicate registrations rather than allowing order-dependent replacement. The importer validates the shared envelope, then delegates payload validation. It reports unsupported records separately from malformed records and preserves source order.

Accept records independently because this screen is an observation report. Do not copy this policy into a payment batch or another operation requiring atomic success. Invalid top-level syntax still prevents identifying individual records and fails the document.

The first valid envelope reserves its domain UUID. This makes duplicate handling independent of extension availability; changing which adapters are installed does not select a different duplicate. It also means a malformed payload can block a later valid duplicate. A different product could reject all duplicates or reconcile revisions, but must define that policy explicitly.

## Alternatives

**An enum and switch:** clearer for a small closed set, with exhaustive compile-time handling. Choose it when independent registration is not required. This exercise explicitly makes that change pressure real.

**Mutable or actor-owned registry:** supports live installation but introduces update ordering and snapshot semantics. The app only needs composition-time configuration, so an immutable value is sufficient. The UI composes a new registry rather than mutating a shared one.

**Fallback to the latest supported version:** risks applying the wrong units or required fields. Prefer explicit adapters for supported versions and a visible unsupported result.

**Fail the whole bulletin:** simpler and appropriate for atomic work. Here it unnecessarily removes valid observations. Per-record containment costs richer outcomes and explicit duplicate policy.

**Entity-owned SwiftUI views:** retained in the foundation lesson. The advanced route projects plain facts so the import contract can remain independent of SwiftUI. This limits rich type-specific presentation; add a rendering extension only if product requirements justify it.

## Introduction into an existing app

Keep the existing path while specifying envelope IDs and version meaning with the producer. Run the new importer against representative saved fixtures; compare accepted counts, unsupported schemas and rejected reasons. Ship behind an explicit composition choice, observe aggregate failures without logging raw payloads, and retain a rollback path. Decide separately whether partial recovery is appropriate for each consumer. None of that rollout infrastructure is implemented in this offline lab.

## Revisit when

Inputs become large, extensions need live updates, unsupported records need durable replay, or cross-record integrity matters. Those constraints may change lifetime, storage, policy and performance boundaries. The design is closed only against adding another registered schema, not against every future requirement.
