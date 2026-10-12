import Foundation

actor SampleEditionSource: GuideEditionSource {
    private var revision = 1
    private var offline = false

    func configure(revision: Int, offline: Bool) {
        self.revision = revision
        self.offline = offline
    }

    func readEdition() async throws -> GuideEdition {
        let revision = revision
        let offline = offline
        try await Task.sleep(for: .milliseconds(350))
        try Task.checkCancellation()
        if offline { throw SampleError.offline }
        return try Self.edition(revision: revision)
    }

    static func edition(revision: Int) throws -> GuideEdition {
        try GuideEdition(revision: revision, figures: [
            GuideFigure(id: UUID(uuidString: "01000000-0000-0000-0000-000000000001")!,
                        kind: .angel, name: "Michael", attribute: revision == 1 ? "Protection" : "Guardianship", rank: "Archangels"),
            GuideFigure(id: UUID(uuidString: "01000000-0000-0000-0000-000000000002")!,
                        kind: .demon, name: "Lucifer", attribute: "Pride", rank: "Princes")
        ])
    }
    enum SampleError: Error { case offline }
}

@MainActor
final class GuideLabSession: ObservableObject {
    let source: SampleEditionSource
    let model: GuideEditionModel
    init() {
        let source = SampleEditionSource()
        self.source = source
        model = GuideEditionModel(source: source)
    }
}
