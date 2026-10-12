import XCTest
@testable import LSPExample

@MainActor
final class AsyncVoiceContractTests: XCTestCase {
    private let identity = VoiceIdentity(id: UUID(), name: "Test voice")

    func testEverySupportedVoiceHonoursTheSameRepeatedOutcomeChecks() async throws {
        let voices: [any AsyncVoice] = [ImmediateVoice(identity: identity),
                                       DelayedVoice(identity: identity, pause: {}),
                                       UnavailableVoice(identity: identity)]
        for voice in voices {
            let before = voice.identity
            for _ in 0..<2 {
                let cue = PerformanceCue()
                let outcome = try await voice.perform(cue: cue)
                XCTAssertEqual(VoiceContract.violations(before: before, after: voice.identity, cue: cue, outcome: outcome), [])
            }
        }
    }

    func testUnavailableIsAnAllowedOutcomeRatherThanAnLSPViolation() async throws {
        let voice = UnavailableVoice(identity: identity)
        let cue = PerformanceCue()
        let outcome = try await voice.perform(cue: cue)
        XCTAssertEqual(VoiceContract.violations(before: identity, after: voice.identity, cue: cue, outcome: outcome), [])
        guard case .unavailable = outcome else { return XCTFail("Expected declared unavailability") }
    }

    func testSharedChecksCatchWrongCueAndBlankResults() async throws {
        let cue = PerformanceCue()
        let wrong = WrongCueVoice(identity: identity)
        let outcome = try await wrong.perform(cue: cue)
        XCTAssertTrue(VoiceContract.violations(before: identity, after: identity, cue: cue, outcome: outcome).contains("Wrong cue identity."))
        let blank = VoiceOutcome.performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id, description: " "))
        XCTAssertTrue(VoiceContract.violations(before: identity, after: identity, cue: cue, outcome: blank).contains("Performance description is blank."))
        XCTAssertEqual(VoiceContract.violations(before: identity, after: identity, cue: cue, outcome: .unavailable(" ")), ["Unavailable reason is blank."])
    }

    func testSharedChecksCatchChangedIdentityAndWrongVoice() {
        let cue = PerformanceCue()
        let changed = VoiceIdentity(id: UUID(), name: "Changed voice")
        let outcome = VoiceOutcome.performed(VoiceReceipt(voiceID: changed.id, cueID: cue.id, description: "Different voice"))
        let violations = VoiceContract.violations(before: identity, after: changed, cue: cue, outcome: outcome)
        XCTAssertTrue(violations.contains("Identity changed during performance."))
        XCTAssertTrue(violations.contains("Wrong voice identity."))
        XCTAssertTrue(violations.contains("Description omits the voice name."))
    }

    func testSupportedVoicesRejectCancellationAtEntryThroughTheSameCheck() async {
        let voices: [any AsyncVoice] = [ImmediateVoice(identity: identity),
                                       DelayedVoice(identity: identity, pause: {}),
                                       UnavailableVoice(identity: identity)]
        for voice in voices {
            let rejects = await rejectsCancelledEntry(voice)
            XCTAssertTrue(rejects)
        }
        let ignores = await rejectsCancelledEntry(IgnoresCancellationVoice(identity: identity))
        XCTAssertFalse(ignores)
    }

    func testDelayedVoiceRechecksCancellationAfterSuspensionAndCanPerformAgain() async throws {
        let gate = VoiceGate()
        let voice = DelayedVoice(identity: identity, pause: { _ = try await gate.wait() })
        let cancelled = Task { try await voice.perform(cue: PerformanceCue()) }
        await gate.waitForArrival(1)
        cancelled.cancel()
        // The injected pause deliberately ignores cancellation; the voice must recheck.
        await gate.complete(1, with: .success(()))
        do { _ = try await cancelled.value; XCTFail("Expected cooperative cancellation") }
        catch is CancellationError { } catch { XCTFail("Unexpected error: \(error)") }
        let cue = PerformanceCue()
        let repeated = Task { try await voice.perform(cue: cue) }
        await gate.waitForArrival(2)
        await gate.complete(2, with: .success(()))
        let outcome = try await repeated.value
        XCTAssertEqual(VoiceContract.violations(before: identity, after: voice.identity, cue: cue, outcome: outcome), [])
    }

    /// MainActor scheduling guarantees cancel happens before this new task can enter the voice.
    private func rejectsCancelledEntry(_ voice: any AsyncVoice) async -> Bool {
        let task = Task { try await voice.perform(cue: PerformanceCue()) }
        task.cancel()
        do { _ = try await task.value; return false }
        catch is CancellationError { return true } catch { return false }
    }
}

final class AsyncOrchestraTests: XCTestCase {
    private let first = VoiceIdentity(id: UUID(), name: "First")
    private let second = VoiceIdentity(id: UUID(), name: "Second")

    func testReportsStayInEnsembleOrderWhenSecondVoiceFinishesFirst() async throws {
        let firstGate = VoiceGate()
        let secondGate = VoiceGate()
        let voices = [GatedVoice(identity: first, gate: firstGate), GatedVoice(identity: second, gate: secondGate)]
        let task = Task { try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: voices) }
        await firstGate.waitForArrival(1)
        await secondGate.waitForArrival(1)
        await secondGate.complete(1, with: .success(()))
        await firstGate.complete(1, with: .success(()))
        let reports = try await task.value
        XCTAssertEqual(reports.map(\.voice), [first, second])
        for report in reports { guard case .performed = report.result else { return XCTFail("Expected valid receipts") } }
    }

    func testUnavailableVoiceDoesNotDiscardOtherVoices() async throws {
        let reports = try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [ImmediateVoice(identity: first), UnavailableVoice(identity: second)])
        XCTAssertEqual(reports.count, 2)
        guard case .performed = reports[0].result, case .unavailable = reports[1].result else { return XCTFail("Expected independent terminal outcomes") }
    }

    func testWrongCueIsContainedAsAContractViolation() async throws {
        let reports = try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [ImmediateVoice(identity: first), WrongCueVoice(identity: second)])
        guard case .violation(let reason) = reports[1].result else { return XCTFail("Expected a rejected receipt") }
        XCTAssertEqual(reason, "Wrong cue identity.")
        guard case .performed = reports[0].result else { return XCTFail("A bad conformer must not discard a valid peer") }
    }

    func testPreparationRequirementAndUnexpectedCancellationAreUndeclaredErrors() async throws {
        for voice: any AsyncVoice in [NeedsPreparationVoice(identity: first), UnexpectedCancellationVoice(identity: first)] {
            let reports = try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [voice])
            guard case .violation = reports[0].result else { return XCTFail("Expected a contract violation") }
        }
    }

    func testCancelledConductorDiscardsLateSuccessFromNoncooperativeVoice() async {
        let gate = VoiceGate()
        let task = Task { try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [GatedVoice(identity: first, gate: gate)]) }
        await gate.waitForArrival(1)
        task.cancel()
        await gate.complete(1, with: .success(()))
        do { _ = try await task.value; XCTFail("Cancelled work must not produce a completed report") }
        catch is CancellationError { } catch { XCTFail("Unexpected error: \(error)") }
    }

    func testEmptyEnsembleCompletesWithNoReports() async throws {
        let reports = try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [])
        XCTAssertEqual(reports, [])
    }

    func testDuplicateIdentityIsRejectedBeforePerformance() async {
        do {
            _ = try await AsyncOrchestra.perform(cue: PerformanceCue(), voices: [ImmediateVoice(identity: first), UnavailableVoice(identity: first)])
            XCTFail("Expected duplicate identity rejection")
        } catch AsyncOrchestraError.duplicateVoiceIdentity { } catch { XCTFail("Unexpected error: \(error)") }
    }
}

@MainActor
final class AsyncRehearsalModelTests: XCTestCase {
    private let identity = VoiceIdentity(id: UUID(), name: "Controlled voice")

    func testCancellationIsVisibleBeforeNoncooperativeChildrenFinish() async {
        let gate = VoiceGate()
        let model = AsyncRehearsalModel()
        let task = model.start(voices: [GatedVoice(identity: identity, gate: gate)])
        await gate.waitForArrival(1)
        model.cancel()
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertTrue(model.reports.isEmpty)
        await gate.complete(1, with: .success(()))
        await task.value
        XCTAssertEqual(model.phase, .cancelled)
        XCTAssertTrue(model.reports.isEmpty)
    }

    func testOldCueCannotOverwriteNewerCompletedReport() async {
        let gate = VoiceGate()
        let model = AsyncRehearsalModel()
        let old = model.start(voices: [GatedVoice(identity: identity, gate: gate)])
        await gate.waitForArrival(1)
        await model.start(voices: [ImmediateVoice(identity: identity)]).value
        let accepted = model.reports
        await gate.complete(1, with: .success(()))
        await old.value
        XCTAssertEqual(model.phase, .completed)
        XCTAssertEqual(model.reports, accepted)
    }

    func testChangingEnsembleResetsCueAndRejectsLateErrors() async {
        let gate = VoiceGate()
        let model = AsyncRehearsalModel()
        let old = model.start(voices: [GatedVoice(identity: identity, gate: gate)])
        await gate.waitForArrival(1)
        model.reset()
        await gate.complete(1, with: .failure(PreparationError.required))
        await old.value
        XCTAssertEqual(model.phase, .idle)
        XCTAssertTrue(model.reports.isEmpty)
    }
}

/// Explicit arrivals and releases establish order without sleeps or timing guesses.
private actor VoiceGate {
    private var count = 0
    private var pending: [Int: CheckedContinuation<Void, Error>] = [:]
    private var arrivals: [Int: CheckedContinuation<Void, Never>] = [:]
    func wait() async throws {
        count += 1
        let number = count
        try await withCheckedThrowingContinuation { continuation in
            pending[number] = continuation
            arrivals.removeValue(forKey: number)?.resume()
        }
    }
    func waitForArrival(_ number: Int) async {
        if pending[number] != nil { return }
        await withCheckedContinuation { arrivals[number] = $0 }
    }
    func complete(_ number: Int, with result: Result<Void, Error>) {
        pending.removeValue(forKey: number)!.resume(with: result)
    }
}

private struct GatedVoice: AsyncVoice {
    let identity: VoiceIdentity
    let gate: VoiceGate
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        try await gate.wait() // Intentionally ignores cancellation to test containment.
        return .performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id, description: "\(identity.name) returned late."))
    }
}
private struct IgnoresCancellationVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        .performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id, description: identity.name))
    }
}
private enum PreparationError: Error { case required }
private struct NeedsPreparationVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome { throw PreparationError.required }
}
private struct UnexpectedCancellationVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome { throw CancellationError() }
}
