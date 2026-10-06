import SwiftUI

struct AngelListView: View {
    @StateObject private var viewModel: AngelCatalogViewModel
    @State private var selectedID: String?

    init(dataService: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: AngelCatalogViewModel(dataService: dataService))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if viewModel.isLoading { ProgressView("Opening the angels index…") }
            else if let error = viewModel.errorMessage {
                GuideNotice(message: error) { Task { await viewModel.load() } }
            } else if let hierarchy = viewModel.hierarchy {
                if hierarchy.angels.isEmpty {
                    GuideNotice(message: "No angels in this volume.")
                } else {
                    let selected = hierarchy.angels.first { $0.id == selectedID } ?? hierarchy.angels[0]
                    GuideStyle.label("\(hierarchy.rank.uppercased()) / PLATE \(plateNumber(selected, in: hierarchy.angels))")
                        .foregroundStyle(GuideStyle.annotation)
                    AngelDetailView(angel: selected)
                    Text(hierarchy.describeHierarchy()).font(.system(.caption, design: .serif))
                        .foregroundStyle(GuideStyle.secondary).accessibilityIdentifier("hierarchy-description")
                    GuideStyle.divider
                    GuideStyle.label("IN THIS ORDER")
                    VStack(spacing: 0) {
                        ForEach(hierarchy.angels) { figure in
                            Button { selectedID = figure.id } label: {
                                HStack(spacing: 14) {
                                    AngelView(angel: figure)
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

    private func plateNumber(_ figure: AngelModel, in figures: [AngelModel]) -> String {
        String(format: "%02d", (figures.firstIndex(where: { $0.id == figure.id }) ?? 0) + 1)
    }
}
