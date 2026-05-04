//
//  SRP_Example_Angels_and_DemonsTests.swift
//  SRP-Example-Angels-and-DemonsTests
//
//  Created by Gobias LTD on 12/12/2023.
//

import XCTest
@testable import SRP_Example_Angels_and_Demons

final class SRP_Example_Angels_and_DemonsTests: XCTestCase {

    func testHierarchyDescriptionCanChangeWithoutTouchingViewsOrDataService() {
        let hierarchy = AngelHierarchy(
            rank: "Archangel",
            angels: [
                AngelModel(name: "Michael", power: "Healing"),
                AngelModel(name: "Gabriel", power: "Messenger")
            ]
        )

        XCTAssertEqual(hierarchy.describeHierarchy(), "Hierarchy: Archangel with 2 angels.")
    }

    func testModelOwnsAngelPowerDescriptionWithoutNeedingAView() {
        let angel = AngelModel(name: "Michael", power: "Healing")

        XCTAssertEqual(angel.describePower(), "Michael possesses the power of Healing.")
    }

}
