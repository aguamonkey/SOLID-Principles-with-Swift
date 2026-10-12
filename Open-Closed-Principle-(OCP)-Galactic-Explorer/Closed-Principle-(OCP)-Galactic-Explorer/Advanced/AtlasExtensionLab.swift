import SwiftUI

struct AtlasExtensionLab: View {
    @State private var includeAsteroid = false
    @State private var rows: [AtlasImportRow] = []
    @State private var failure: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    AtlasStyle.caption("ATLAS / INCOMING DISPATCH")
                    Spacer()
                    AtlasStyle.caption("LAB 02B")
                }.foregroundStyle(AtlasStyle.secondary)
                AtlasStyle.divider
                Text("Beyond the\nknown sky.")
                    .font(.system(.largeTitle, design: .serif).weight(.medium))
                Text("Four records. One import contract.")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(AtlasStyle.secondary)
                HStack(alignment: .firstTextBaseline) {
                    Text("\(acceptedCount)").font(.system(size: 54, weight: .light, design: .serif))
                    VStack(alignment: .leading) {
                        AtlasStyle.caption("OBSERVATIONS ACCEPTED")
                        Text("of \(rows.count) received").font(.subheadline)
                    }
                }.accessibilityElement(children: .combine)
                .accessibilityIdentifier("lab-summary")
                Button("Swap supported types") {
                    includeAsteroid.toggle()
                    load()
                }
                .buttonStyle(AtlasActionStyle())
                .accessibilityIdentifier("lab-extension")
                .accessibilityHint(includeAsteroid ? "Switch to Planet v1 only" : "Include Asteroid v1")
                Text(includeAsteroid ? "Planet v1 + Asteroid v1" : "Planet v1 only")
                    .font(.system(.caption, design: .monospaced))
                    .accessibilityIdentifier("lab-registry")
                if let failure { Text(failure).foregroundStyle(AtlasStyle.accent) }
                ForEach(rows) { row in
                    AtlasStyle.divider
                    report(row)
                }
                AtlasStyle.divider
                Text("A new registry is composed for each demonstration. Unsupported records are reported; their payloads are not interpreted.")
                    .font(.footnote).foregroundStyle(AtlasStyle.secondary)
                AtlasStyle.caption("BUNDLED STUDY DATA / NO NETWORK")
            }.padding(24)
        }
        .clipped()
        .foregroundStyle(AtlasStyle.ink)
        .background(AtlasStyle.paper.ignoresSafeArea())
        .onAppear { load() }
    }

    private var acceptedCount: Int {
        rows.filter { if case .accepted = $0.outcome { return true }; return false }.count
    }

    @ViewBuilder private func report(_ row: AtlasImportRow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            switch row.outcome {
            case let .accepted(name, facts):
                AtlasStyle.caption("0\(row.id + 1) / ACCEPTED")
                Text(name).font(.system(.title2, design: .serif))
                ForEach(Array(facts.enumerated()), id: \.offset) { _, fact in
                    AtlasFactView(label: fact.label, value: fact.value)
                }
            case let .unsupported(name, schema):
                AtlasStyle.caption("0\(row.id + 1) / UNSUPPORTED").foregroundStyle(AtlasStyle.accent)
                Text(name).font(.system(.title2, design: .serif))
                Text("\(schema.type) · version \(schema.version)")
                    .font(.system(.subheadline, design: .monospaced))
            case let .rejected(reason):
                AtlasStyle.caption("0\(row.id + 1) / REJECTED").foregroundStyle(AtlasStyle.accent)
                Text(reason).font(.system(.title2, design: .serif))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("lab-row-\(row.id)")
    }

    private func load() {
        do {
            let registry = try AtlasLabComposition.registry(includeAsteroid: includeAsteroid)
            rows = try AtlasImporter(registry: registry).read(AtlasLabComposition.bulletin)
            failure = nil
        } catch {
            rows = []
            failure = "The bulletin could not be imported."
        }
    }
}
