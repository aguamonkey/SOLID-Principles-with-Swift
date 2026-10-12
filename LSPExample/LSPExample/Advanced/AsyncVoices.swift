import Foundation

struct ImmediateVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        try Task.checkCancellation()
        return .performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id,
                                      description: "\(identity.name) answers the conductor’s cue."))
    }
}

struct DelayedVoice: AsyncVoice {
    let identity: VoiceIdentity
    var pause: @Sendable () async throws -> Void = { try await Task.sleep(nanoseconds: 3_000_000_000) }
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        try Task.checkCancellation()
        try await pause()
        try Task.checkCancellation()
        return .performed(VoiceReceipt(voiceID: identity.id, cueID: cue.id,
                                      description: "\(identity.name) answers after a measured rest."))
    }
}

struct UnavailableVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        try Task.checkCancellation()
        return .unavailable("This voice is unavailable for the current rehearsal.")
    }
}

/// Deliberate teaching counterexample: valid Swift conformance, invalid cue receipt.
struct WrongCueVoice: AsyncVoice {
    let identity: VoiceIdentity
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome {
        try Task.checkCancellation()
        var wrongCue = cue.id.uuid
        wrongCue.0 ^= 1 // Guaranteed mismatch, rather than a random-ID comparison.
        return .performed(VoiceReceipt(voiceID: identity.id, cueID: UUID(uuid: wrongCue),
                                      description: "\(identity.name) answers a different cue."))
    }
}
