import AVFoundation
import XCTest
@testable import LSPExample

final class LSPExampleTests: XCTestCase {
    func testEveryCatalogInstrumentHonoursPlayableContractWithoutPreparation() {
        for info in InstrumentInfoStore.all {
            XCTAssertEqual(contractViolations(info.makePlayable()), [], info.name)
        }
    }

    func testContractCheckDetectsAConformerThatReturnsNoPerformance() {
        // This type compiles, but violates a behavioural postcondition.
        XCTAssertTrue(contractViolations(SilentInstrument()).contains("blank description"))
    }

    func testOrchestraCanPerformWithAnyPlayableInstrument() {
        let orchestra = OrchestraService()
        let instruments = InstrumentInfoStore.all.map { $0.makePlayable() }
        instruments.forEach(orchestra.addInstrument)

        let result = orchestra.performConcert()

        XCTAssertEqual(result, instruments.map { $0.play() })
        XCTAssertEqual(orchestra.instruments.map(\.id), instruments.map(\.id))
    }

    func testNewPlayableWorksWithoutTuningOrBlowing() {
        let percussion = TestPercussion()
        XCTAssertEqual(contractViolations(percussion), [])
        let orchestra = OrchestraService()
        orchestra.addInstrument(percussion)

        XCTAssertEqual(orchestra.performConcert(), ["Drum plays a steady rhythm."])
        XCTAssertTrue(orchestra.tuneAll().isEmpty)
        XCTAssertTrue(orchestra.blowAll().isEmpty)
    }

    func testCapabilitySpecificOperationsDoNotBreakPlayableSubstitution() {
        let orchestra = OrchestraService()
        InstrumentInfoStore.all.map { $0.makePlayable() }.forEach(orchestra.addInstrument)
        let before = orchestra.performConcert()

        XCTAssertEqual(orchestra.tuneAll().count, 3)
        XCTAssertEqual(orchestra.blowAll().count, 2)
        XCTAssertEqual(orchestra.performConcert(), before)
        orchestra.instruments.forEach { XCTAssertEqual(contractViolations($0), []) }
    }

    func testOneCatalogIdentityCannotJoinTwice() {
        let info = InstrumentInfoStore.all[0]
        let orchestra = OrchestraService()
        orchestra.addInstrument(info.makePlayable())
        orchestra.addInstrument(info.makePlayable())
        XCTAssertEqual(orchestra.instruments.count, 1)
    }

    func testRestingVoiceLeavesTheConcertAndCanRejoin() {
        let orchestra = OrchestraService()
        let violin = StringInstrument(id: UUID(), name: "Violin")
        let percussion = TestPercussion()
        orchestra.addInstrument(violin)
        orchestra.addInstrument(percussion)

        orchestra.removeInstrument(id: violin.id)
        XCTAssertFalse(orchestra.contains(violin.id))
        XCTAssertEqual(orchestra.performConcert(), [percussion.play()])
        orchestra.addInstrument(violin)
        XCTAssertEqual(orchestra.performConcert(), [percussion.play(), violin.play()])
    }

    func testEmptyOrchestraHasNoPerformancesOrCapabilities() {
        let orchestra = OrchestraService()
        orchestra.removeInstrument(id: UUID())
        XCTAssertEqual(orchestra.performConcert(), [])
        XCTAssertEqual(orchestra.tuneAll(), [])
        XCTAssertEqual(orchestra.blowAll(), [])
    }

    func testCatalogHasUniqueIdentitiesAndDecodableAudioPreviews() throws {
        let catalog = InstrumentInfoStore.all
        XCTAssertEqual(catalog.count, 3)
        XCTAssertEqual(Set(catalog.map(\.id)).count, catalog.count)
        for info in catalog {
            XCTAssertEqual(info.makePlayable().id, info.id)
            XCTAssertEqual(info.makePlayable().name, info.name)
            let url = try XCTUnwrap(Bundle.main.url(forResource: info.soundFileName, withExtension: nil))
            let player = try AVAudioPlayer(contentsOf: url)
            XCTAssertGreaterThan(player.duration, 0, info.name)
        }
    }

    /// Use this same check for each new conformer. Calling twice without preparation
    /// catches one-shot/preparation requirements as well as weakened result guarantees.
    private func contractViolations(_ instrument: any Playable) -> [String] {
        let id = instrument.id
        let name = instrument.name
        var violations: [String] = []
        for _ in 0..<2 {
            let description = instrument.play()
            if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                violations.append("blank description")
            }
            if !description.contains(name) { violations.append("missing instrument name") }
            if instrument.id != id { violations.append("changed identity") }
            if instrument.name != name { violations.append("changed name") }
        }
        return violations
    }
}

private struct TestPercussion: Playable {
    let id = UUID()
    let name = "Drum"
    func play() -> String { "Drum plays a steady rhythm." }
}

private struct SilentInstrument: Playable {
    let id = UUID()
    let name = "Silent instrument"
    func play() -> String { "" }
}
