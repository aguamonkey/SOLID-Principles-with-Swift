# Solution notes · editorial language is display policy

[Exercise](EXERCISE.md) · [Advanced lesson](README.md)

These are implementation notes, not a second runnable implementation.

Add an explicit language value to `GuideEditorial`, with English as its default. Let editorial-owned resources provide narrative/index templates, annotations and translations of the small fixture rank/attribute vocabulary. Preserve raw facts in `GuideEdition` and schema 1 in `GuideExport`.

For example, `Protection` may display as `Protección` and `Archangels` as `Arcángeles`; the JSON should still contain `Protection` and `Archangels`. Keep Michael's name and UUID intact. Make the fallback policy visible in the decision notes: for this bounded exercise, preserving an unmapped source value is defensible. A production system may require stable vocabulary identifiers rather than matching English strings.

Test the original English output, each Spanish voice, translated annotations, unchanged identity and unchanged export bytes. Use the same loaded snapshot for every comparison. A source spy should show one read even after several language/consumer switches. The model and supplier should need no localisation-specific changes.

If the UI exposes a selector, keep language as presentation state. Full app localisation would also involve controls, failure messages, accessibility, pluralisation and locale-aware formatting; translating this projector alone does not implement all of those. Consider String Catalogs and translator context when moving beyond the fixture exercise.

The change checklist is editorial policy/resources, its tests, and optionally the guide controls. Editing export DTOs or rewriting source facts would mix different owners' decisions.
