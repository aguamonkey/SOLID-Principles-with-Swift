import Foundation

enum VoiceReportResult: Equatable, Sendable {
    case performed(String), unavailable(String), violation(String)
}

struct VoiceReport: Equatable, Sendable, Identifiable {
    let voice: VoiceIdentity
    let result: VoiceReportResult
    var id: UUID { voice.id }
}

enum AsyncOrchestraError: Error { case duplicateVoiceIdentity }

/// One uniform operation. Completion order may vary; report order follows the ensemble.
enum AsyncOrchestra {
    static func perform(cue: PerformanceCue, voices: [any AsyncVoice]) async throws -> [VoiceReport] {
        try Task.checkCancellation()
        guard Set(voices.map { $0.identity.id }).count == voices.count else {
            throw AsyncOrchestraError.duplicateVoiceIdentity
        }
        let reports = await withTaskGroup(of: (Int, VoiceReport?).self) { group in
            for (index, voice) in voices.enumerated() {
                group.addTask { (index, await report(voice, cue: cue)) }
            }
            var ordered: [(Int, VoiceReport)] = []
            for await (index, report) in group {
                if let report { ordered.append((index, report)) }
            }
            return ordered.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
        // Structured tasks drain before return. No completed report escapes cancellation.
        try Task.checkCancellation()
        return reports
    }

    private static func report(_ voice: any AsyncVoice, cue: PerformanceCue) async -> VoiceReport? {
        let identity = voice.identity
        do {
            try Task.checkCancellation()
            let outcome = try await voice.perform(cue: cue)
            try Task.checkCancellation()
            let failures = VoiceContract.violations(before: identity, after: voice.identity, cue: cue, outcome: outcome)
            if !failures.isEmpty { return VoiceReport(voice: identity, result: .violation(failures.joined(separator: " "))) }
            switch outcome {
            case .performed(let receipt): return VoiceReport(voice: identity, result: .performed(receipt.description))
            case .unavailable(let reason): return VoiceReport(voice: identity, result: .unavailable(reason))
            }
        } catch {
            if Task.isCancelled { return nil }
            // Unexpected cancellation and transport/preparation errors violate this contract.
            return VoiceReport(voice: identity, result: .violation("Undeclared error instead of a terminal outcome."))
        }
    }
}
