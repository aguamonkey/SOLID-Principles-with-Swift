# Solution notes · a second explicit adapter

[Exercise](EXERCISE.md) · [Advanced lesson](README.md)

These are implementation notes, not a second runnable implementation.

Add a `PlanetV2Record: Decodable` with a nested payload containing `radiusMetres: Double`. Decode it with a new local `JSONDecoder`, reject nonfinite or nonpositive values, divide by 1,000, and return the same `RADIUS` fact in kilometres. Register that closure under `AtlasSchema(type: "Planet", version: 2)` alongside v1 in composition.

Do not widen the shared envelope or put a Planet check in the importer. The version is an extension dispatch key; the measurement belongs to the payload adapter. Version 2's existing bulletin record would become accepted with a radius of 2 km. The damaged v1 row would remain rejected.

Test v1 against its previous expected facts, v2 conversion with a known measurement, invalid v2 payloads, v3 unsupported, duplicate v2 registration, and the unchanged asteroid outcome. A fixtures test with both versions provides compatibility evidence. Avoid testing only the new closure in isolation.

Deploy the client adapter before the producer relies on v2 readability. Older clients still report unsupported records; if those clients must display every record, the producer needs an agreed compatibility or minimum-version policy. Do not equate an additive JSON field with a semantic version change: changing units requires explicit interpretation even when both values are numbers.

A shared internal measurement model could reduce repeated formatting once multiple adapters need it. That is an optional refactor, not a reason to build a migration framework for two small payloads.
