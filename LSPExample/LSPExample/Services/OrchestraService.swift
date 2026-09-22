import Combine
import Foundation

/// The concert depends only on Playable's behaviour. Optional capabilities are
/// queried separately and are never prerequisites for taking part in a concert.
final class OrchestraService: ObservableObject {
    @Published private(set) var instruments: [any Playable] = []

    func addInstrument(_ instrument: any Playable) {
        guard !contains(instrument.id) else { return }
        instruments.append(instrument)
    }

    func removeInstrument(id: UUID) {
        instruments.removeAll { $0.id == id }
    }

    func contains(_ id: UUID) -> Bool {
        instruments.contains { $0.id == id }
    }

    func performConcert() -> [String] {
        instruments.map { $0.play() }
    }

    func tuneAll() -> [String] {
        instruments.compactMap { ($0 as? Tunable)?.tune() }
    }

    func blowAll() -> [String] {
        instruments.compactMap { ($0 as? Blowable)?.blow() }
    }
}
