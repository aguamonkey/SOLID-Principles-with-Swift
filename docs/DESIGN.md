# Swift Studies design direction

[Back to the learning path](../README.md)

The collection shares a small `JB / Swift Studies` signature. Each app uses a different visual structure rooted in its subject, while preserving native scrolling, text scaling, accessible controls, and system appearance.

| App | Direction | Interaction that supports the lesson | Status |
| --- | --- | --- | --- |
| Angels and Demons | A typeset celestial field guide, indexed figures, serif titles, red annotations | Browse figures and their independently supplied descriptions | Approved concept |
| Galactic Explorer | An astronomical atlas, numbered observations, ruled schematic map, ink and paper | New entity types enter the same map, index, and detail flow | Implemented in SwiftUI |
| Orchestra | A rehearsal score with instrument staves and a conductor's cue | Different playable instruments respond to the same performance action | Implemented in SwiftUI |
| EcoShop | A shopkeeper's ledger with ruled entries and a separate stockroom | Browsing depends on reading; stockroom actions use writing | Implemented in SwiftUI |
| Network Service | A patchboard with replaceable inputs and a fixed receiver | Swap a source while keeping the consuming view model unchanged | Approved concept |

## Galactic Explorer boundaries

The atlas visualises the loaded collection; it does not know about planets, stars, or comets. Diagram positions depend on collection order and are labelled schematic. Each entity owns its detailed presentation through `SpaceEntity.makeView()`.

Stored entity IDs support stable selection during a decoded object's lifetime. New types must provide that identity. A reload with newly decoded objects begins a new observation selection unless the data supplies persistent identity.

Keep the design understandable for learners: styling lives in `OrbitalAtlasStyle`, the map in `OrbitalMapView`, and selection/loading in `ExplorerViewModel`. The primary action browses observations. Type registration stays in the composition function where students can study and extend it.

## Orchestra boundaries

The printed-score interface selects voices and issues a conductor action. The orchestra then invokes `Playable.play()` uniformly. The explicit behavioural contract and shared checks are the lesson's starting point; students can read those before the SwiftUI drawing code.

The score notation is illustrative. Performances are text descriptions, while individual recorded previews belong to `AudioService`. An instrument does not need a recording or an optional capability to honour `Playable`. The catalog creates concrete implementations using a typed kind at the composition boundary; no type checks appear in the concert loop.

## EcoShop boundaries

The Goods register is a reader-only screen. Stockroom composes a reader for its list with a writer for mutations; its editor takes a prefilled value and only a writer. The app composition supplies one shared product store. Switching back to Goods reloads that store. Orders and Reviews keep their independent workflow dependencies.

Ruled entries, serif headings, green ink, GBP prices, and product references give the shop its ledger identity. The content is a fictional sample shop, not a claim about certified sustainable products. Adaptive colours and stacked large-text rows keep the design usable beyond the default screenshot size.

## Screenshot criteria

Capture the actual running app after checking loading, selection, empty/error behaviour, light/dark appearance, and accessibility text. Include real content and hide no important failures. Concept previews are design references, not app screenshots.
