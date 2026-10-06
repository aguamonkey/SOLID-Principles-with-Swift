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

    func testSingularHierarchyDescriptionsWithoutAViewOrService() {
        let hierarchy = DemonHierarchy(rank: "Greater Demon", demons: [DemonModel(name: "Lucifer", ability: "Illusion")])
        XCTAssertEqual(hierarchy.describeHierarchy(), "Hierarchy: Greater Demon with 1 demon.")
        let angels = AngelHierarchy(rank: "Archangel", angels: [AngelModel(name: "Michael", power: "Healing")])
        XCTAssertEqual(angels.describeHierarchy(), "Hierarchy: Archangel with 1 angel.")
    }

    func testDemonModelOwnsItsAbilityDescription() {
        XCTAssertEqual(DemonModel(name: "Mammon", ability: "Greed").describeAbility(), "Mammon wields the ability of Greed.")
    }

    @MainActor
    func testAngelLoadingUsesOnlyTheAngelDataOperation() async {
        let service = FixtureService()
        let model = AngelCatalogViewModel(dataService: service)
        await model.load()
        XCTAssertEqual(model.hierarchy?.angels, service.angels)
        XCTAssertEqual(model.hierarchy?.rank, "Archangel")
        XCTAssertEqual(service.angelReads, 1)
        XCTAssertEqual(service.demonReads, 0)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor
    func testDemonLoadingUsesOnlyTheDemonDataOperation() async {
        let service = FixtureService()
        let model = DemonCatalogViewModel(dataService: service)
        await model.load()
        XCTAssertEqual(model.hierarchy?.demons, service.demons)
        XCTAssertEqual(service.angelReads, 0)
        XCTAssertEqual(service.demonReads, 1)
        XCTAssertNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
    }

    @MainActor
    func testEmptyResultsProduceEmptyHierarchies() async {
        let service = FixtureService()
        service.angels = []
        service.demons = []
        let angels = AngelCatalogViewModel(dataService: service)
        let demons = DemonCatalogViewModel(dataService: service)
        await angels.load()
        await demons.load()
        XCTAssertEqual(angels.hierarchy?.angels.count, 0)
        XCTAssertEqual(demons.hierarchy?.demons.count, 0)
        XCTAssertNil(angels.errorMessage)
        XCTAssertNil(demons.errorMessage)
    }

    @MainActor
    func testAngelFailureCanRecoverWithoutChangingDescriptionOrLayout() async {
        let service = FixtureService()
        service.shouldFail = true
        let model = AngelCatalogViewModel(dataService: service)
        await model.load()
        XCTAssertNotNil(model.errorMessage)
        XCTAssertNil(model.hierarchy)
        XCTAssertFalse(model.isLoading)
        service.shouldFail = false
        await model.load()
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.hierarchy?.angels, service.angels)
    }

    @MainActor
    func testDemonFailureCanRecover() async {
        let service = FixtureService()
        service.shouldFail = true
        let model = DemonCatalogViewModel(dataService: service)
        await model.load()
        XCTAssertNotNil(model.errorMessage)
        XCTAssertFalse(model.isLoading)
        service.shouldFail = false
        await model.load()
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.hierarchy?.demons, service.demons)
    }

    @MainActor
    func testCancellationFinishesLoadingWithoutDisplayingAnError() async {
        let service = FixtureService()
        service.shouldCancel = true
        let angels = AngelCatalogViewModel(dataService: service)
        let demons = DemonCatalogViewModel(dataService: service)
        await angels.load()
        await demons.load()
        XCTAssertNil(angels.errorMessage)
        XCTAssertNil(demons.errorMessage)
        XCTAssertFalse(angels.isLoading)
        XCTAssertFalse(demons.isLoading)
    }

    func testFiguresWithTheSameNameHaveIndependentIdentity() {
        let first = AngelModel(name: "Michael", power: "Healing")
        let second = AngelModel(name: "Michael", power: "Messenger")
        XCTAssertNotEqual(first.id, second.id)
    }

}

private final class FixtureService: DataServiceProtocol {
    var angels = [AngelModel(id: "a", name: "Michael", power: "Healing")]
    var demons = [DemonModel(id: "d", name: "Lucifer", ability: "Illusion")]
    var shouldFail = false
    var shouldCancel = false
    private(set) var angelReads = 0
    private(set) var demonReads = 0
    func getAllAngels() async throws -> [AngelModel] {
        angelReads += 1
        if shouldCancel { throw CancellationError() }
        if shouldFail { throw FixtureError.unavailable }
        return angels
    }
    func getAllDemons() async throws -> [DemonModel] {
        demonReads += 1
        if shouldCancel { throw CancellationError() }
        if shouldFail { throw FixtureError.unavailable }
        return demons
    }
}
private enum FixtureError: Error { case unavailable }
