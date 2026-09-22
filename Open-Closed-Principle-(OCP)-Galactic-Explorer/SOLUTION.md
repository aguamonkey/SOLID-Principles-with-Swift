# Exercise solution: 02 · Open/Closed

[Back to the lesson](README.md#exercise)

## 1. Add a concrete entity

Create `Asteroid.swift` in the app's Models group and enable app target membership. This proposed implementation supplies the stable stored ID required by `SpaceEntity`:

```swift
import Foundation
import SwiftUI

struct Asteroid: SpaceEntity {
    let id: UUID
    let name: String
    let description: String
    let diameter: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        diameter = try container.decode(Double.self, forKey: .diameter)
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, diameter
    }

    func makeView() -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text(name)
                Text("Diameter: \(diameter, specifier: "%.1f") km")
            }
        )
    }
}
```

`Encodable` can be synthesised from the coding keys. This ID is stable for the decoded value's lifetime; preserving identity across reloads would require an ID in the data or another documented identity scheme.

## 2. Register it at composition

In `makeProductionEntityRegistry()`, before returning the registry:

```swift
registry.register("Asteroid") { decoder in
    try Asteroid(from: decoder)
}
```

## 3. Extend the sample data

Append this object to the array in `entities.json`, preserving valid JSON:

```json
{
  "type": "Asteroid",
  "name": "Vesta",
  "description": "A large asteroid in the main belt",
  "diameter": 525.0
}
```

## 4. Verify the production path

The lesson's linked test file already demonstrates a test-only asteroid. Once you add a production `Asteroid`, remove or rename that private fixture so it does not shadow the app type. Use `makeProductionEntityRegistry()` in an additional test to verify the actual app registration, then decode through `AnySpaceEntity` and assert the name and diameter.

Run the unit tests and the app. Vesta should appear in the map and object index. Select it to inspect its details. For the stretch test, decode an unregistered type and assert that decoding throws.

## Change checklist

| Change | Why |
| --- | --- |
| Add `Asteroid.swift` and target membership | Supply the new data type and its view |
| Edit `EntityRegistration.swift` | Choose the new type at the app boundary |
| Edit `entities.json` | Supply a sample instance |
| Extend the unit tests | Check the new production registration and decoded fields |
| Leave `EntityRegistry.decode`, the loader, and atlas screen unchanged | Reuse the existing extension point |

The snippets describe an exercise solution; the production app has not already been extended with this asteroid.
