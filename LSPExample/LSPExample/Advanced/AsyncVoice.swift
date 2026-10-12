import Foundation

struct VoiceIdentity: Equatable, Sendable {
    let id: UUID
    let name: String
}

struct PerformanceCue: Equatable, Sendable {
    let id: UUID
    init(id: UUID = UUID()) { self.id = id }
}

struct VoiceReceipt: Equatable, Sendable {
    let voiceID: UUID
    let cueID: UUID
    let description: String
}

enum VoiceOutcome: Equatable, Sendable {
    case performed(VoiceReceipt)
    case unavailable(String)
}

/// Descriptive performance, not audio. Every conformer must:
/// - keep identity stable and work repeatedly without concrete preparation;
/// - return one terminal outcome identifying this cue/voice, or a nonblank unavailable reason;
/// - throw CancellationError when its task is cancelled at entry or after suspension;
/// - avoid other thrown errors: expected failures belong in the declared outcome.
/// Cancellation is cooperative; this contract does not promise a wall-clock deadline.
protocol AsyncVoice: Sendable {
    var identity: VoiceIdentity { get }
    func perform(cue: PerformanceCue) async throws -> VoiceOutcome
}

/// Value checks are shared by the executable caller and contract tests.
enum VoiceContract {
    static func violations(before: VoiceIdentity, after: VoiceIdentity,
                           cue: PerformanceCue, outcome: VoiceOutcome) -> [String] {
        var failures: [String] = []
        if before != after { failures.append("Identity changed during performance.") }
        if before.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failures.append("Voice name is blank.")
        }
        switch outcome {
        case .performed(let receipt):
            if receipt.voiceID != before.id { failures.append("Wrong voice identity.") }
            if receipt.cueID != cue.id { failures.append("Wrong cue identity.") }
            if receipt.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("Performance description is blank.")
            }
            if !receipt.description.contains(before.name) { failures.append("Description omits the voice name.") }
        case .unavailable(let reason):
            if reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                failures.append("Unavailable reason is blank.")
            }
        }
        return failures
    }
}
