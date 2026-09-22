//
//  Closed_Principle__OCP__Galactic_ExplorerTests.swift
//  Closed-Principle-(OCP)-Galactic-ExplorerTests
//
//  Created by Gobias LTD on 23/12/2023.
//

import XCTest
import SwiftUI
@testable import Open_Closed_Principle__OCP__Galactic_Explorer

final class Closed_Principle__OCP__Galactic_ExplorerTests: XCTestCase {

    func testBundledEntitiesDecodeThroughProductionRegistry() async throws {
        let loader = JSONSpaceEntityLoader(registry: makeProductionEntityRegistry())

        let entities = try await loader.loadEntities()

        XCTAssertEqual(entities.map(\.name), ["Earth", "Sun", "Halley"])
        let star = try XCTUnwrap(entities.first { $0 is Star } as? Star)
        XCTAssertEqual(star.type, "G-Type")
    }

    @MainActor
    func testAtlasSelectsNewConformerAndWrapsWithoutKnowingItsType() async {
        let earth = Planet(name: "Earth", description: "Home", numberOfMoons: 1)
        let asteroid = Asteroid(name: "Vesta", description: "New discovery", diameter: 525)
        let model = ExplorerViewModel(loader: FixedEntityLoader(entities: [earth, asteroid]))

        await model.fetch()
        XCTAssertEqual(model.selectedID, earth.id)
        model.selectNext()
        XCTAssertEqual(model.selectedID, asteroid.id)
        XCTAssertEqual(model.selectedEntity?.name, "Vesta")
        model.selectNext()
        XCTAssertEqual(model.selectedID, earth.id)
        model.select(UUID())
        XCTAssertEqual(model.selectedID, earth.id, "Unknown IDs must not lose selection")
        model.select(asteroid.id)
        await model.fetch()
        XCTAssertEqual(model.selectedID, asteroid.id, "Retain selection when the same entities reload")
    }

    @MainActor
    func testEmptyAtlasHasNoSelection() async {
        let model = ExplorerViewModel(loader: FixedEntityLoader(entities: []))
        await model.fetch()
        model.selectNext()
        XCTAssertNil(model.selectedEntity)
        XCTAssertNil(model.selectedIndex)
        XCTAssertFalse(model.isLoading)
        XCTAssertNil(model.errorMessage)
    }

    @MainActor
    func testFailedLoadCanBeRetried() async {
        let loader = RetryEntityLoader()
        let model = ExplorerViewModel(loader: loader)
        await model.fetch()
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)

        loader.shouldFail = false
        await model.fetch()
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.selectedEntity?.name, "Earth")
        XCTAssertFalse(model.isLoading)
    }

    func testDecodedEntitiesKeepTheirIdentity() async throws {
        let entities = try await JSONSpaceEntityLoader(registry: makeProductionEntityRegistry()).loadEntities()
        let originalIDs = entities.map(\.id)
        XCTAssertEqual(entities.map(\.id), originalIDs)
        XCTAssertEqual(Set(originalIDs).count, entities.count)
    }

    func testBeforeAndAfterShowsWhyRegistrationKeepsDecoderClosedForChange() throws {
        XCTAssertThrowsError(try BeforeSolidEntitySwitch.decode(type: "Asteroid"))

        let registry = EntityRegistry()
        registry.register("Asteroid") { decoder in
            try Asteroid(from: decoder)
        }

        let json = """
        {
            "type": "Asteroid",
            "name": "Vesta",
            "description": "A large asteroid in the main belt",
            "diameter": 525.0
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.userInfo[.entityRegistry] = registry
        let decoded = try decoder.decode(AnySpaceEntity.self, from: json)

        XCTAssertTrue(decoded.entity is Asteroid)
    }

    func testFactoryDecodesRegisteredEntityWithoutChangingCoreDecoder() throws {
        let registry = EntityRegistry()
        registry.register("Asteroid") { decoder in
            try Asteroid(from: decoder)
        }
        
        let json = """
        {
            "type": "Asteroid",
            "name": "Vesta",
            "description": "A large asteroid in the main belt",
            "diameter": 525.0
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.userInfo[.entityRegistry] = registry
        let decoded = try decoder.decode(AnySpaceEntity.self, from: json)
        
        let asteroid = try XCTUnwrap(decoded.entity as? Asteroid)
        XCTAssertEqual(asteroid.name, "Vesta")
        XCTAssertEqual(asteroid.diameter, 525.0)
    }
}

private enum BeforeSolidEntitySwitch {
    static func decode(type: String) throws -> String {
        switch type {
        case "Planet", "Star", "Comet":
            return type
        default:
            throw UnsupportedEntityError.typeRequiresEditingSwitch
        }
    }

    enum UnsupportedEntityError: Error {
        case typeRequiresEditingSwitch
    }
}

private final class Asteroid: SpaceEntity {
    let id = UUID()
    let name: String
    let description: String
    let diameter: Double

    init(name: String, description: String, diameter: Double) {
        self.name = name
        self.description = description
        self.diameter = diameter
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        diameter = try container.decode(Double.self, forKey: .diameter)
    }

    func makeView() -> AnyView {
        AnyView(Text(name))
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, diameter
    }
}

private struct FixedEntityLoader: SpaceEntityDataLoader {
    let entities: [any SpaceEntity]
    func loadEntities() async throws -> [any SpaceEntity] { entities }
}

private final class RetryEntityLoader: SpaceEntityDataLoader {
    var shouldFail = true
    func loadEntities() async throws -> [any SpaceEntity] {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return [Planet(name: "Earth", description: "Home", numberOfMoons: 1)]
    }
}
