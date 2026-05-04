//
//  LSPExampleTests.swift
//  LSPExampleTests
//
//  Created by Gobias LTD on 31/12/2023.
//

import XCTest
@testable import LSPExample

final class LSPExampleTests: XCTestCase {

    func testOrchestraCanPerformWithAnyPlayableInstrument() {
        let orchestra = OrchestraService()
        let violin = StringInstrument(id: UUID(), name: "Violin")
        let trumpet = BrassInstrument(id: UUID(), name: "Trumpet", valveCount: 3)
        let flute = WindInstrument(id: UUID(), name: "Flute", reedType: "lip plate")
        
        orchestra.addInstrument(violin)
        orchestra.addInstrument(trumpet)
        orchestra.addInstrument(flute)
        
        let performance = orchestra.performConcert()
        
        XCTAssertEqual(performance.count, 3)
        XCTAssertTrue(performance[0].contains("Violin"))
        XCTAssertTrue(performance[1].contains("Trumpet"))
        XCTAssertTrue(performance[2].contains("Flute"))
    }

    func testCapabilitySpecificOperationsDoNotBreakPlayableSubstitution() {
        let orchestra = OrchestraService()
        orchestra.addInstrument(StringInstrument(id: UUID(), name: "Violin"))
        orchestra.addInstrument(BrassInstrument(id: UUID(), name: "Trumpet", valveCount: 3))
        
        XCTAssertEqual(orchestra.performConcert().count, 2)
        XCTAssertEqual(orchestra.tuneAll().count, 2)
        XCTAssertEqual(orchestra.blowAll().count, 1)
    }
}
