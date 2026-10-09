# Swift Studies design direction

[Back to the learning path](../README.md)

The collection shares a small `JB / Swift Studies` signature. Each app uses a different visual structure rooted in its subject, while preserving native scrolling, text scaling, accessible controls, and system appearance.

| App | Direction | Interaction that supports the lesson | Status |
| --- | --- | --- | --- |
| Angels and Demons | A typeset celestial field guide, indexed figures, serif titles, red annotations | Browse figures and their independently supplied descriptions | Implemented in SwiftUI |
| Galactic Explorer | An astronomical atlas, numbered observations, ruled schematic map, ink and paper | New entity types enter the same map, index, and detail flow | Implemented in SwiftUI |
| Orchestra | A rehearsal score with instrument staves and a conductor's cue | Different playable instruments respond to the same performance action | Implemented in SwiftUI |
| EcoShop | A shopkeeper's ledger with ruled entries and a separate stockroom | Browsing depends on reading; stockroom actions use writing | Implemented in SwiftUI |
| Network Service | A patchboard with replaceable inputs and a fixed receiver | Swap a source while keeping the consuming view model unchanged | Implemented in SwiftUI |

## Angels and Demons boundaries

The field guide gives each figure a numbered plate, a decorative collection mark, and an index row. `ContentView` selects the collection; each list view selects a figure. Dedicated catalog view models supply loading/error state. Models and hierarchies supply descriptions independently of SwiftUI. Visual components live in `GuideStyle.swift`.

The red annotations and serif typography use adaptive colours and scalable text. Figure identities come from the supplier, so duplicate names do not merge index entries. The sample ranks and powers are illustrative teaching content.

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

## Network Service boundaries

The patchboard selects local sample, delayed, or disconnected adapters at `NetworkComposition`. Every input feeds the same repository contract. The receiver accepts only an injected repository and logger. Source changes construct a fresh receiver instance and cancel the previous reception; its implementation stays unchanged.

A schematic cable, physical-style source switches, and a green terminal readout distinguish this lesson. The diagram is not a live network trace. All three demo inputs are offline, and the UI says so. The retained URLSession adapter is an extension point rather than a dependency of the receiver.

The [advanced DIP refresh lab](../ModularNetworkServiceExample/Advanced/README.md) reuses the paper, terminal and type treatments with a separate KEEP / REFRESH screen. Its retained composition session owns an actor cache and consumer model together. Saved content remains visible while refreshing or offline; the original patchboard keeps its source-switch/reset semantics. Navigation uses two tabs so learners can compare both behaviours in one app.

## Screenshot criteria

Capture the actual running app after checking loading, selection, empty/error behaviour, light/dark appearance, and accessibility text. Include real content and hide no important failures. Concept previews are design references, not app screenshots.
