import Combine
import Foundation

/// Owns catalog loading and recovery; no view layout or description formatting.
@MainActor
final class AngelCatalogViewModel: ObservableObject {
    private let dataService: DataServiceProtocol
    private var loadVersion = 0
    @Published private(set) var hierarchy: AngelHierarchy?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    init(dataService: DataServiceProtocol) { self.dataService = dataService }

    func load() async {
        loadVersion += 1
        let version = loadVersion
        isLoading = true
        errorMessage = nil
        defer { if version == loadVersion { isLoading = false } }
        do {
            let figures = try await dataService.getAllAngels()
            guard version == loadVersion else { return }
            hierarchy = AngelHierarchy(rank: "Archangel", angels: figures)
        } catch is CancellationError { }
        catch {
            guard version == loadVersion else { return }
            errorMessage = "Could not open the angels index: \(error.localizedDescription)"
        }
    }
}

/// Owns catalog loading and recovery; no view layout or description formatting.
@MainActor
final class DemonCatalogViewModel: ObservableObject {
    private let dataService: DataServiceProtocol
    private var loadVersion = 0
    @Published private(set) var hierarchy: DemonHierarchy?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    init(dataService: DataServiceProtocol) { self.dataService = dataService }

    func load() async {
        loadVersion += 1
        let version = loadVersion
        isLoading = true
        errorMessage = nil
        defer { if version == loadVersion { isLoading = false } }
        do {
            let figures = try await dataService.getAllDemons()
            guard version == loadVersion else { return }
            hierarchy = DemonHierarchy(rank: "Greater Demon", demons: figures)
        } catch is CancellationError { }
        catch {
            guard version == loadVersion else { return }
            errorMessage = "Could not open the demons index: \(error.localizedDescription)"
        }
    }
}
