import Foundation

struct GuideFigure: Equatable, Sendable {
    enum Kind: String, Sendable { case angel, demon }
    let id: UUID
    let kind: Kind
    let name: String
    let attribute: String
    let rank: String
}

enum GuideEditionError: Error, Equatable {
    case invalidRevision
    case duplicateIdentity
    case incompleteFigure
}

/// Shared data invariants belong here, before either consumer can project an edition.
struct GuideEdition: Equatable, Sendable {
    let revision: Int
    let figures: [GuideFigure]

    init(revision: Int, figures: [GuideFigure]) throws {
        guard revision > 0 else { throw GuideEditionError.invalidRevision }
        guard Set(figures.map(\.id)).count == figures.count else {
            throw GuideEditionError.duplicateIdentity
        }
        guard figures.allSatisfy({ figure in
            [figure.name, figure.attribute, figure.rank].allSatisfy {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        }) else { throw GuideEditionError.incompleteFigure }
        self.revision = revision
        self.figures = figures
    }
}

protocol GuideEditionSource: Sendable {
    func readEdition() async throws -> GuideEdition
}
