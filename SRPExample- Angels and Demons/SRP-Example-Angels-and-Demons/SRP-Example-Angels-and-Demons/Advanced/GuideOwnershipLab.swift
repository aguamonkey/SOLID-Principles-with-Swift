import SwiftUI

struct GuideOwnershipLab: View {
    @StateObject private var session = GuideLabSession()
    var body: some View { GuideOwnershipScreen(model: session.model, source: session.source) }
}

private struct GuideOwnershipScreen: View {
    @ObservedObject var model: GuideEditionModel
    let source: SampleEditionSource
    @State private var exportVisible = false
    @State private var compactProse = false
    @State private var offline = false
    @State private var requestedRevision = 1
    @State private var configuring = false
    @State private var visible = false
    @Environment(\.dynamicTypeSize) private var textSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack { GuideStyle.label("THE EDITION ROOM"); Spacer(); GuideStyle.label("LAB 01B") }
                    .foregroundStyle(GuideStyle.secondary)
                GuideStyle.divider
                Text("One edition.\nTwo readings.")
                    .font(.system(.largeTitle, design: .serif))
                    .fixedSize(horizontal: false, vertical: true)
                Text("Field notes and a structured record, drawn from the same facts.")
                    .font(.system(.subheadline, design: .serif)).foregroundStyle(GuideStyle.secondary)
                consumerPicker
                if let edition = model.edition {
                    GuideStyle.label("EDITION \(edition.revision) / \(edition.figures.count) FIGURES")
                        .foregroundStyle(GuideStyle.annotation).accessibilityIdentifier("edition-revision")
                    if exportVisible { GuideExportPreview(edition: edition) }
                    else {
                        Button("Change editorial voice") { compactProse.toggle() }
                            .buttonStyle(GuideLabActionStyle()).accessibilityIdentifier("editorial-voice")
                        GuideStyle.label(compactProse ? "INDEX NOTES" : "NARRATIVE NOTES")
                        GuideReadingPreview(edition: edition, voice: compactProse ? .indexNotes : .narrative)
                    }
                } else if !model.isLoading && model.warning == nil {
                    Text("No edition has been loaded.").font(.body)
                }
                if model.isLoading { ProgressView("Opening edition…") }
                if let warning = model.warning {
                    GuideNotice(message: warning).accessibilityElement(children: .combine).accessibilityIdentifier("edition-warning")
                }
                GuideStyle.divider
                GuideStyle.label("SOURCE CONTROLS / LOCAL FIXTURE")
                Button("Refresh edition") { model.refresh() }
                    .buttonStyle(GuideLabActionStyle()).accessibilityIdentifier("edition-refresh")
                    .disabled(configuring || model.isLoading)
                Button("Switch sample edition") {
                    requestedRevision = requestedRevision == 1 ? 2 : 1
                    configureAndRefresh()
                }.buttonStyle(GuideLabActionStyle()).accessibilityIdentifier("edition-switch")
                    .disabled(configuring || model.isLoading)
                Button("Toggle source connection") {
                    offline.toggle()
                    configureAndRefresh()
                }.buttonStyle(GuideLabActionStyle()).accessibilityIdentifier("edition-connection")
                    .disabled(configuring || model.isLoading)
                GuideStyle.label(offline ? "SOURCE OFFLINE" : "SOURCE AVAILABLE")
                Text("Export is a preview only. No file is saved. Figures and ranks are study fixtures.")
                    .font(.footnote).foregroundStyle(GuideStyle.secondary)
            }.padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .clipped().background(GuideStyle.paper).foregroundStyle(GuideStyle.ink).tint(GuideStyle.annotation)
        .onAppear { visible = true; if !configuring { model.refresh() } }
        .onDisappear { visible = false; model.cancel() }
    }

    private var consumerPicker: some View {
        let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            Button("Read the guide") { exportVisible = false }
                .buttonStyle(GuideLabActionStyle(selected: !exportVisible))
                .accessibilityIdentifier("edition-guide")
                .accessibilityValue(exportVisible ? "Not selected" : "Selected")
            Button("Inspect export") { exportVisible = true }
                .buttonStyle(GuideLabActionStyle(selected: exportVisible))
                .accessibilityIdentifier("edition-export")
                .accessibilityValue(exportVisible ? "Selected" : "Not selected")
        }.buttonStyle(GuideLabActionStyle()).frame(minHeight: 44)
    }

    private func configureAndRefresh() {
        configuring = true
        let revision = requestedRevision
        let offline = offline
        model.cancel()
        Task {
            await source.configure(revision: revision, offline: offline)
            configuring = false
            if visible { model.refresh() }
        }
    }
}

/// This consumer knows editorial wording and display, not source access or JSON field names.
private struct GuideReadingPreview: View {
    let edition: GuideEdition
    let voice: GuideEditorial.Voice
    var body: some View {
        if edition.figures.isEmpty {
            Text("This edition contains no figures.").font(.body)
        }
        ForEach(GuideEditorial(voice: voice).readings(from: edition)) { reading in
            GuideStyle.divider
            VStack(alignment: .leading, spacing: 8) {
                GuideStyle.label(reading.annotation).foregroundStyle(GuideStyle.secondary)
                Text(reading.name).font(.system(.title, design: .serif))
                Text(reading.prose).font(.system(.body, design: .serif))
                    .fixedSize(horizontal: false, vertical: true)
            }.accessibilityElement(children: .combine)
                .accessibilityIdentifier("reading-\(reading.id.uuidString)")
        }
    }
}

/// This consumer renders the export contract; it never triggers another source read.
private struct GuideExportPreview: View {
    let edition: GuideEdition
    private var text: String {
        do { return String(decoding: try GuideExport().encode(edition), as: UTF8.self) }
        catch { return "Export could not be encoded." }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GuideStyle.label("JSON / SCHEMA 1").foregroundStyle(GuideStyle.secondary)
            Text(text).font(.system(.caption, design: .monospaced))
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled).accessibilityIdentifier("edition-json")
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(GuideStyle.rule.opacity(0.22))
            .overlay(alignment: .leading) { Rectangle().fill(GuideStyle.annotation).frame(width: 2) }
    }
}

private struct GuideLabActionStyle: ButtonStyle {
    var selected = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .monospaced))
            .padding(.horizontal, 14).padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(selected ? GuideStyle.paper : GuideStyle.ink)
            .background(selected ? GuideStyle.ink : .clear)
            .overlay(Rectangle().stroke(GuideStyle.rule, lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
