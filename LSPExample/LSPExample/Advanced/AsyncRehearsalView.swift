import SwiftUI

struct AsyncRehearsalView: View {
    @StateObject private var model = AsyncRehearsalModel()
    @State private var scenario: AsyncScenario = .ready
    @Environment(\.dynamicTypeSize) private var textSize
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 38

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                RehearsalStyle.divider
                ViewThatFits(in: .horizontal) {
                    HStack {
                        RehearsalStyle.label("ORCHESTRA / CONTRACT LAB")
                        Spacer(minLength: 12)
                        RehearsalStyle.label("SCORE 03 / B")
                    }.fixedSize(horizontal: true, vertical: false)
                    VStack(alignment: .leading, spacing: 8) {
                        RehearsalStyle.label("ORCHESTRA / CONTRACT LAB")
                        RehearsalStyle.label("SCORE 03 / B")
                    }
                }
                RehearsalStyle.divider
                Text("Same cue.\nSame promise.")
                    .font(.system(size: titleSize, design: .serif)).tracking(-1)
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                Text("Different voices. One set of expectations.")
                    .font(.system(.subheadline, design: .serif)).italic().foregroundStyle(RehearsalStyle.secondary)
                sourcePicker
                Text("Violin answers immediately. Flute waits, reports unavailable, or returns the wrong cue.")
                    .font(.caption).foregroundStyle(RehearsalStyle.secondary)
                RehearsalStyle.divider
                RehearsalStyle.label(status).accessibilityIdentifier("async-status")
                if model.phase == .running {
                    ProgressView("Waiting for every selected voice…")
                    Button("Cancel cue") { model.cancel() }
                        .buttonStyle(ConductorButtonStyle()).accessibilityIdentifier("async-cancel")
                }
                Button(model.phase == .running ? "Replace the cue" : "Give an async cue") {
                    model.start(voices: AsyncRehearsalComposition.voices(for: scenario))
                }.buttonStyle(ConductorButtonStyle()).accessibilityIdentifier("async-perform")
                ForEach(model.reports) { report in
                    reportRow(report)
                }
                Text("Unavailable is permitted. A wrong cue is rejected.\nLocal descriptions only; no audio playback.")
                    .font(.footnote).foregroundStyle(RehearsalStyle.secondary)
                RehearsalStyle.divider
                RehearsalStyle.label("JB / SWIFT STUDIES       ·       ASYNC REHEARSAL")
            }
            .padding(20).frame(maxWidth: 620).frame(maxWidth: .infinity)
        }
        .clipped()
        .background(RehearsalStyle.paper).foregroundStyle(RehearsalStyle.ink)
        .onDisappear { model.cancel() }
    }

    private var sourcePicker: some View {
        let layout = textSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            ForEach(AsyncScenario.allCases) { item in
                Button {
                    scenario = item
                    model.reset()
                } label: {
                    Text(item.rawValue).font(.system(.caption, design: .monospaced))
                        .padding(14).frame(maxWidth: .infinity, minHeight: 48)
                        .foregroundStyle(item == scenario ? RehearsalStyle.paper : RehearsalStyle.ink)
                        .background(item == scenario ? RehearsalStyle.ink : .clear)
                        .overlay(Rectangle().stroke(RehearsalStyle.ink, lineWidth: 1))
                }.buttonStyle(.plain).accessibilityIdentifier("cue-source-\(item.rawValue)")
                    .accessibilityValue(item == scenario ? "Selected" : "Not selected")
            }
        }
    }

    private var status: String {
        switch model.phase {
        case .idle: return "AT YOUR CUE"
        case .running: return "WAITING FOR VOICES"
        case .cancelled: return "CUE CANCELLED"
        case .rejected: return "ENSEMBLE REJECTED / DUPLICATE IDENTITY"
        case .completed:
            return model.reports.contains { if case .violation = $0.result { return true }; return false }
                ? "CONTRACT VIOLATION DETECTED" : "REHEARSAL COMPLETE"
        }
    }

    private func reportRow(_ report: VoiceReport) -> some View {
        let result: (String, String)
        switch report.result {
        case .performed(let text): result = ("PERFORMED", text)
        case .unavailable(let reason): result = ("UNAVAILABLE / CONTRACT HONOURED", reason)
        case .violation(let reason): result = ("CONTRACT VIOLATION", reason)
        }
        return VStack(alignment: .leading, spacing: 10) {
            Text(report.voice.name).font(.system(.title2, design: .serif))
            RehearsalStyle.label(result.0).foregroundStyle(RehearsalStyle.accent)
            Text(result.1).font(.body).fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("async-report.\(report.voice.name)")
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .overlay(Rectangle().stroke(RehearsalStyle.rule, lineWidth: 1))
    }
}
