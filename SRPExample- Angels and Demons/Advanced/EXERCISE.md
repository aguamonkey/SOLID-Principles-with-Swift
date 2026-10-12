# Exercise · localise the guide without changing the export

[Advanced lesson](README.md) · [Separate solution notes](SOLUTION.md)

An editor requests a Spanish guide preview. The integration consumer still expects schema 1 with the original machine values. Add an explicit English/Spanish editorial language choice without changing the shared edition or exported fields.

Before editing, map each change to its owner. Decide how to translate fixture ranks and attributes for display while leaving names, IDs and raw source facts unchanged. Explain what a real localisation system would need beyond this small exercise.

Acceptance criteria:

- Both editorial voices work in both languages; figure names and identities remain unchanged.
- English retains its current wording. Spanish has translated prose, annotations and the fixture rank/attribute labels.
- Switching language does not fetch another edition or change export bytes.
- JSON schema, raw `kind`, `attribute`, `rank` and revision stay unchanged.
- Pure projection tests check both languages, identity, and export isolation. Add a UI check if the selector is exposed.
- Record a fallback policy for unmapped fixture values. Do not silently modify source facts to satisfy translation.

The baseline only has two English editorial voices. This localisation extension is deliberately left for the learner.
