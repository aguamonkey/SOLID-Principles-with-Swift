import SwiftUI

struct ContentView: View {
    private let catalog: [InstrumentInfo]
    @StateObject private var orchestra: OrchestraService
    @State private var audio = AudioService()
    @State private var responses: [String] = []
    @State private var cue: Int?
    @State private var audioError: String?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 46

    init(catalog: [InstrumentInfo] = InstrumentInfoStore.all) {
        self.catalog = catalog
        let orchestra = OrchestraService()
        catalog.forEach { orchestra.addInstrument($0.makePlayable()) }
        _orchestra = StateObject(wrappedValue: orchestra)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                masthead
                heading.padding(.vertical, 18)
                RehearsalStyle.divider
                Text("Tap to rest a voice. Preview its sound.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(RehearsalStyle.secondary)
                    .padding(.vertical, 14)
                ForEach(Array(catalog.enumerated()), id: \.element.id) { index, info in
                    InstrumentRowView(info: info, row: index, isIncluded: orchestra.contains(info.id),
                                      cue: cue, toggle: { toggle(info) }, preview: {
                        audioError = audio.play(soundFileName: info.soundFileName)
                    })
                }
                HStack {
                    RehearsalStyle.label("ILLUSTRATIVE SCORE")
                    Spacer()
                    Button("Stop audio") { audio.stop() }
                        .font(.system(.caption, design: .monospaced))
                        .frame(minHeight: 44)
                }
                .foregroundStyle(RehearsalStyle.secondary)
                if let audioError {
                    Text(audioError).font(.callout).foregroundStyle(RehearsalStyle.accent)
                }
                rehearsal.padding(.top, 6).padding(.bottom, 18)
                Button {
                    responses = orchestra.performConcert()
                    cue = ((cue ?? -1) + 1) % 5
                } label: {
                    HStack {
                        Text(cue == nil ? "Give the downbeat" : "Repeat the cue")
                        Spacer(minLength: 10)
                        Image(systemName: "play.fill")
                    }
                }
                .buttonStyle(ConductorButtonStyle())
                .disabled(orchestra.instruments.isEmpty)
                .accessibilityIdentifier("performConcert")
                Text(orchestra.instruments.isEmpty
                     ? "Include a voice to begin the rehearsal."
                     : "One cue. A description from every selected voice.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(RehearsalStyle.secondary)
                    .padding(.top, 13)
                if !responses.isEmpty {
                    OrchestraPerformanceView(responses: responses)
                }
                footer.padding(.top, 25)
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .frame(maxWidth: 620).frame(maxWidth: .infinity)
        }
        .clipped()
        .background(RehearsalStyle.paper.ignoresSafeArea())
        .foregroundStyle(RehearsalStyle.ink)
        .tint(RehearsalStyle.accent)
        .onDisappear { audio.stop() }
    }

    private func toggle(_ info: InstrumentInfo) {
        if orchestra.contains(info.id) {
            orchestra.removeInstrument(id: info.id)
        } else {
            orchestra.addInstrument(info.makePlayable())
        }
        // A report belongs to the ensemble that produced it.
        responses = []
        cue = nil
        audio.stop()
        audioError = nil
    }

    private var masthead: some View {
        VStack(spacing: 10) {
            RehearsalStyle.divider
            ViewThatFits(in: .horizontal) {
                HStack {
                    RehearsalStyle.label("ORCHESTRA / REHEARSAL")
                    Spacer(minLength: 12)
                    RehearsalStyle.label("SCORE 03")
                }
                VStack(alignment: .leading, spacing: 8) {
                    RehearsalStyle.label("ORCHESTRA / REHEARSAL")
                    RehearsalStyle.label("SCORE 03")
                }
            }
            RehearsalStyle.divider
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Many voices.\nOne score.")
                .font(.system(size: titleSize, design: .serif)).tracking(-2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("rehearsalHeading")
            Text("A small ensemble, assembled by you.")
                .font(.system(.subheadline, design: .serif)).italic()
                .foregroundStyle(RehearsalStyle.secondary)
        }
    }

    private var rehearsal: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 14))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
        return layout {
            VStack(alignment: .leading, spacing: 7) {
                Text(cue == nil ? "At your cue." : "Cue received.")
                    .font(.system(.title2, design: .serif))
                RehearsalStyle.label(cue == nil ? "READY TO REHEARSE" : "DESCRIPTIVE PERFORMANCE")
                    .foregroundStyle(RehearsalStyle.secondary)
            }
            Spacer(minLength: 0)
            Text("\(orchestra.instruments.count) voices\nOne ensemble")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(RehearsalStyle.secondary)
                .accessibilityIdentifier("ensembleCount")
        }
        .padding(16)
        .overlay(Rectangle().stroke(RehearsalStyle.rule, lineWidth: 1))
    }

    private var footer: some View {
        VStack(spacing: 12) {
            RehearsalStyle.divider
            ViewThatFits(in: .horizontal) {
                HStack {
                    RehearsalStyle.label("JB / SWIFT STUDIES")
                    Spacer(minLength: 12)
                    RehearsalStyle.label("REHEARSAL ROOM · 03")
                }
                VStack(alignment: .leading, spacing: 8) {
                    RehearsalStyle.label("JB / SWIFT STUDIES")
                    RehearsalStyle.label("REHEARSAL ROOM · 03")
                }
            }
        }
        .foregroundStyle(RehearsalStyle.secondary)
        .padding(.bottom, 12)
    }
}
