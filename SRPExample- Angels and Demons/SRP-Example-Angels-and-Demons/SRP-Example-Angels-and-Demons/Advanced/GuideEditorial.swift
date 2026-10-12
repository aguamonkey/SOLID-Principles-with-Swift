import Foundation

struct GuideReading: Identifiable, Equatable {
    let id: UUID
    let name: String
    let annotation: String
    let prose: String
}

/// Editorial wording can evolve without changing source facts or the export schema.
struct GuideEditorial {
    enum Voice { case narrative, indexNotes }
    let voice: Voice

    func readings(from edition: GuideEdition) -> [GuideReading] {
        edition.figures.map { figure in
            let prose: String
            switch voice {
            case .narrative:
                prose = "\(figure.name) is recorded among the \(figure.rank). This study edition associates the figure with \(figure.attribute)."
            case .indexNotes:
                prose = "Order: \(figure.rank). Attribute: \(figure.attribute)."
            }
            return GuideReading(id: figure.id, name: figure.name,
                                annotation: figure.kind == .angel ? "ANGEL / FIELD NOTE" : "DEMON / FIELD NOTE",
                                prose: prose)
        }
    }
}
