import SwiftUI

public struct GalacticExplorerView: View {
    @StateObject private var viewModel: ExplorerViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 49

    public init(viewModel: ExplorerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                masthead.padding(.horizontal, 24)
                title.padding(.horizontal, 24).padding(.vertical, 20)

                if let error = viewModel.errorMessage {
                    message(title: "An interrupted observation.", detail: error)
                } else if viewModel.isLoading && viewModel.entities.isEmpty {
                    ProgressView("Opening the atlas…")
                        .frame(maxWidth: .infinity, minHeight: 260)
                } else if viewModel.entities.isEmpty {
                    message(title: "An open sky.", detail: "There are no observations in this collection yet.")
                } else {
                    OrbitalMapView(entities: viewModel.entities, selectedID: viewModel.selectedID,
                                   onSelect: viewModel.select)
                    objectIndex
                    observation.padding(.horizontal, 24).padding(.vertical, 20)
                    if viewModel.entities.count > 1 {
                        Button(action: viewModel.selectNext) {
                            HStack {
                                Text("Next observation")
                                Spacer(minLength: 12)
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(AtlasActionStyle())
                        .accessibilityIdentifier("nextObservation")
                        .padding(.horizontal, 24)
                    }
                }
                footer.padding(.horizontal, 24).padding(.vertical, 20)
            }
            .padding(.top, 12)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(AtlasStyle.ink)
        .background(AtlasStyle.paper.ignoresSafeArea())
        .tint(AtlasStyle.accent)
        .task { await viewModel.fetch() }
    }

    private var masthead: some View {
        VStack(spacing: 10) {
            AtlasStyle.divider
            ViewThatFits(in: .horizontal) {
                HStack {
                    AtlasStyle.caption("GALACTIC EXPLORER")
                    Spacer(minLength: 12)
                    AtlasStyle.caption("ATLAS / 001")
                }
                VStack(alignment: .leading, spacing: 8) {
                    AtlasStyle.caption("GALACTIC EXPLORER")
                    AtlasStyle.caption("ATLAS / 001")
                }
            }
            AtlasStyle.divider
        }
    }

    private var title: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 14))
            : AnyLayout(HStackLayout(alignment: .bottom, spacing: 16))
        return layout {
            Text("Orbital\nregister.")
                .font(.system(size: titleSize, weight: .regular, design: .serif))
                .tracking(-2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 5) {
                Text(String(format: "%02d objects", viewModel.entities.count))
                Text("One collection")
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(AtlasStyle.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var objectIndex: some View {
        // A grid reflows at large text sizes; every entry remains reachable without map precision.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 200 : 96))],
                  alignment: .leading, spacing: 0) {
            ForEach(viewModel.entities, id: \.id) { entity in
                Button { viewModel.select(entity.id) } label: {
                    Text(entity.name)
                        .font(.system(.subheadline, design: .monospaced))
                        .underline(entity.id == viewModel.selectedID)
                        .foregroundStyle(entity.id == viewModel.selectedID ? AtlasStyle.accent : AtlasStyle.secondary)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("index.\(entity.name)")
                .accessibilityAddTraits(entity.id == viewModel.selectedID ? .isSelected : [])
            }
        }
        .padding(.horizontal, 14)
        .overlay(alignment: .bottom) { AtlasStyle.divider }
    }

    @ViewBuilder
    private var observation: some View {
        if let entity = viewModel.selectedEntity, let index = viewModel.selectedIndex {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 18))
            layout {
                Text(String(format: "%02d", index + 1))
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(AtlasStyle.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 12) {
                    Text(entity.name)
                        .font(.system(.title, design: .serif))
                        .accessibilityIdentifier("selectedEntityName")
                        .accessibilityAddTraits(.isHeader)
                    Text(entity.description)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(AtlasStyle.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    // The entity owns its details; no Planet/Star/Comet switch belongs here.
                    entity.makeView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func message(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            AtlasStyle.divider
            Text(title).font(.system(.title, design: .serif))
            Text(detail).font(.system(.body, design: .monospaced))
            Button("Reload observation sheet") {
                Task { await viewModel.fetch() }
            }
            .buttonStyle(AtlasActionStyle())
            .disabled(viewModel.isLoading)
        }
        .padding(24)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            AtlasStyle.divider
            ViewThatFits(in: .horizontal) {
                HStack {
                    AtlasStyle.caption("JB / SWIFT STUDIES")
                    Spacer(minLength: 14)
                    AtlasStyle.caption("ORBITAL ATLAS · 02")
                }
                VStack(alignment: .leading, spacing: 8) {
                    AtlasStyle.caption("JB / SWIFT STUDIES")
                    AtlasStyle.caption("ORBITAL ATLAS · 02")
                }
            }
        }
        .foregroundStyle(AtlasStyle.secondary)
    }
}
