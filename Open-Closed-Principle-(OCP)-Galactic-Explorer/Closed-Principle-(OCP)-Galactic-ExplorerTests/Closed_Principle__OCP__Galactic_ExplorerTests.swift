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

private final class Asteroid: SpaceEntity {
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
