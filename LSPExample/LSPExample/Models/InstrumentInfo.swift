import Foundation

/// Bundled catalog metadata. Concrete construction belongs here, at composition,
/// rather than in the orchestra's uniform performance loop.
struct InstrumentInfo: Identifiable, Decodable {
    enum Kind: String, Decodable {
        case strings, wind, brass

    }

    let id: UUID
    let name: String
    let kind: Kind
    let soundFileName: String

    func makePlayable() -> any Playable {
        switch kind {
        case .strings:
            return StringInstrument(id: id, name: name)
        case .wind:
            return WindInstrument(id: id, name: name, soundSource: "air across the lip plate")
        case .brass:
            return BrassInstrument(id: id, name: name, valveCount: 3)
        }
    }
}
