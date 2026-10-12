# Exercise · evolve the planet payload

[Advanced lesson](README.md) · [Separate solution notes](SOLUTION.md)

The producer adds **Planet version 2**, with `radiusMetres` instead of `radiusKm`. The old version remains in circulation. Add explicit support without changing the import algorithm, registry lookup or report view.

Before editing, list the compatibility promise, the files that should change, and what an older client should show. Decide whether both versions should project to the same fact units.

Acceptance criteria:

- Planet v1 remains accepted and produces the same facts.
- Planet v2 validates a finite, positive `radiusMetres` and converts it to kilometres for the existing fact projection.
- Both versions coexist in one registry. Registering v2 twice still fails construction.
- Missing, wrong-typed or nonpositive v2 measurements are rejected. Version 3 remains unsupported, even with a v1-shaped payload.
- Existing Asteroid results remain unchanged. Unknown fields can be ignored; do not guess a missing version.
- Tests demonstrate each rule. Describe how the producer and older client can deploy independently.

The running baseline deliberately supports Planet v1 only. Attempt this extension before reading the solution; no v2 adapter is hidden in the app.
