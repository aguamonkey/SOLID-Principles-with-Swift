import Foundation

enum AsyncScenario: String, CaseIterable, Identifiable {
    case ready = "Ready", unavailable = "Unavailable", broken = "Broken adapter"
    var id: String { rawValue }
}

/// Source selection is composition. The conductor never recognises concrete voice types.
enum AsyncRehearsalComposition {
    static let violin = VoiceIdentity(id: UUID(uuidString: "03000000-0000-0000-0000-000000000001")!, name: "Violin")
    static let flute = VoiceIdentity(id: UUID(uuidString: "03000000-0000-0000-0000-000000000002")!, name: "Flute")

    static func voices(for scenario: AsyncScenario) -> [any AsyncVoice] {
        let second: any AsyncVoice
        switch scenario {
        case .ready:
            let delay: UInt64 = ProcessInfo.processInfo.environment["ASYNC_CUE_SLOW_INPUT"] == "1" ? 8_000_000_000 : 3_000_000_000
            second = DelayedVoice(identity: flute, pause: { try await Task.sleep(nanoseconds: delay) })
        case .unavailable: second = UnavailableVoice(identity: flute)
        case .broken: second = WrongCueVoice(identity: flute)
        }
        return [ImmediateVoice(identity: violin), second]
    }
}
