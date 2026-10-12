import Combine
import Foundation

@MainActor
final class AsyncRehearsalModel: ObservableObject {
    enum Phase { case idle, running, completed, cancelled, rejected }
    @Published private(set) var phase: Phase = .idle
    @Published private(set) var reports: [VoiceReport] = []
    private var task: Task<Void, Never>?
    private var activeCue: UUID?

    @discardableResult
    func start(voices: [any AsyncVoice]) -> Task<Void, Never> {
        task?.cancel()
        let cue = PerformanceCue()
        activeCue = cue.id
        reports = []
        phase = .running
        let next = Task {
            defer {
                if activeCue == cue.id { activeCue = nil; task = nil }
            }
            do {
                let received = try await AsyncOrchestra.perform(cue: cue, voices: voices)
                guard activeCue == cue.id, !Task.isCancelled else { return }
                reports = received
                phase = .completed
            } catch {
                guard activeCue == cue.id else { return }
                phase = Task.isCancelled || error is CancellationError ? .cancelled : .rejected
            }
        }
        task = next
        return next
    }

    func cancel() {
        guard activeCue != nil else { return }
        task?.cancel()
        task = nil
        activeCue = nil
        phase = .cancelled
    }

    func reset() {
        cancel()
        reports = []
        phase = .idle
    }
}
