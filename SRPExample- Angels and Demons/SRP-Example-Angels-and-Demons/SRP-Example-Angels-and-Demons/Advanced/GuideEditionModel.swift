import Foundation

/// Owns edition loading and publication; it does not own wording or export encoding.
@MainActor
final class GuideEditionModel: ObservableObject {
    @Published private(set) var edition: GuideEdition?
    @Published private(set) var isLoading = false
    @Published private(set) var warning: String?
    private let source: any GuideEditionSource
    private var task: Task<Void, Never>?
    private var active: UUID?

    init(source: any GuideEditionSource) { self.source = source }

    @discardableResult
    func refresh() -> Task<Void, Never> {
        cancel()
        let request = UUID()
        active = request
        isLoading = true
        warning = nil
        let work = Task { [weak self, source] in
            do {
                let incoming = try await source.readEdition()
                try Task.checkCancellation()
                guard let self, self.active == request else { return }
                // Publish one value, so both consumers see the same validated revision.
                self.edition = incoming
                self.finish(request)
            } catch {
                guard let self, self.active == request else { return }
                if !(error is CancellationError) && !Task.isCancelled {
                    self.warning = self.edition == nil
                        ? "No edition could be loaded. Try refreshing."
                        : "Refresh failed. Both readers still use the previous edition."
                }
                self.finish(request)
            }
        }
        task = work
        return work
    }

    func cancel() {
        active = nil
        task?.cancel()
        task = nil
        isLoading = false
    }

    private func finish(_ request: UUID) {
        guard active == request else { return }
        active = nil
        task = nil
        isLoading = false
    }
}
