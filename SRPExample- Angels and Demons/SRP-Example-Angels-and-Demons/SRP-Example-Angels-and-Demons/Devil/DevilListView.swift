import SwiftUI

struct DemonListView: View {
    @StateObject private var viewModel: DemonCatalogViewModel
    @State private var selectedID: String?

    init(dataService: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: DemonCatalogViewModel(dataService: dataService))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if viewModel.isLoading { ProgressView("Opening the demons index…") }
            else if let error = viewModel.errorMessage {
                GuideNotice(message: error) { Task { await viewModel.load() } }
            } else if let hierarchy = viewModel.hierarchy {
                if hierarchy.demons.isEmpty {
                    GuideNotice(message: "No demons in this volume.")
                } else {
                    let selected = hierarchy.demons.first { $0.id == selectedID } ?? hierarchy.demons[0]
                    GuideStyle.label("\(hierarchy.rank.uppercased()) / PLATE \(plateNumber(selected, in: hierarchy.demons))")
                        .foregroundStyle(GuideStyle.annotation)
                    DemonDetailView(demon: selected)
                    Text(hierarchy.describeHierarchy()).font(.system(.caption, design: .serif))
                        .foregroundStyle(GuideStyle.secondary).accessibilityIdentifier("hierarchy-description")
                    GuideStyle.divider
                    GuideStyle.label("IN THIS ORDER")
                    VStack(spacing: 0) {
                        ForEach(hierarchy.demons) { figure in
                            Button { selectedID = figure.id } label: {
                                HStack(spacing: 14) {
                                    DemonView(demon: figure)
                                    Image(systemName: selected.id == figure.id ? "bookmark.fill" : "arrow.up.right")
                                        .foregroundStyle(GuideStyle.annotation).accessibilityHidden(true)
                                }.contentShape(Rectangle())
                            }.buttonStyle(.plain).accessibilityIdentifier("figure-\(figure.id)")
                                .accessibilityValue(selected.id == figure.id ? "Selected" : "Not selected")
                            GuideStyle.divider
                        }
                    }
                }
            }
        }
        .task { await viewModel.load() }
    }

    private func plateNumber(_ figure: DemonModel, in figures: [DemonModel]) -> String {
        String(format: "%02d", (figures.firstIndex(where: { $0.id == figure.id }) ?? 0) + 1)
    }
}
