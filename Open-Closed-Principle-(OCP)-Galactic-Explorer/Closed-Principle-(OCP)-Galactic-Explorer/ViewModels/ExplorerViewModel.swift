import Foundation

@MainActor
public class ExplorerViewModel: ObservableObject {
    @Published public private(set) var entities: [any SpaceEntity] = []
    @Published public private(set) var selectedID: UUID?
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let loader: SpaceEntityDataLoader

    public var selectedEntity: (any SpaceEntity)? {
        entities.first { $0.id == selectedID }
    }

    public var selectedIndex: Int? {
        entities.firstIndex { $0.id == selectedID }
    }

    public init(loader: SpaceEntityDataLoader) {
        self.loader = loader
    }

    public func fetch() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loaded = try await loader.loadEntities()
            try Task.checkCancellation()
            entities = loaded
            if !loaded.contains(where: { $0.id == selectedID }) {
                selectedID = loaded.first?.id
            }
        } catch is CancellationError {
            // A disappearing screen is not a failed observation.
        } catch {
            errorMessage = "The observation sheet could not be loaded. Please try again."
        }
    }

    public func select(_ id: UUID) {
        guard entities.contains(where: { $0.id == id }) else { return }
        selectedID = id
    }

    public func selectNext() {
        guard !entities.isEmpty else { return }
        let next = ((selectedIndex ?? -1) + 1) % entities.count
        selectedID = entities[next].id
    }
}
