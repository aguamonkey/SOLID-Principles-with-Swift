import SwiftUI

/// The source picker is composition UI. The receiver knows no concrete input types.
struct NetworkLabView: View {
    @State private var source: DemoSource = .sample
    @Environment(\.dynamicTypeSize) private var textSize
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 34
    private let logger: LoggingServiceProtocol = LoggingService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    PatchboardStyle.label("NETWORK SERVICE")
                    Spacer()
                    PatchboardStyle.label("UNIT 05")
                }
                Text("PATCH / RECEIVE.").font(.system(size: headingSize, weight: .black))
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                PatchboardStyle.label("LOCAL INPUTS / NO HTTP REQUEST").foregroundStyle(PatchboardStyle.secondary)
                Rectangle().fill(PatchboardStyle.ink).frame(height: 3).accessibilityHidden(true)
                PatchboardStyle.label("01 — SELECT A SOURCE")
                sourcePicker
                Text(source.detail).font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(PatchboardStyle.secondary)
                PatchCable(input: source.index)
                ContentView(networkRepository: NetworkComposition.repository(for: source, logger: logger),
                            logger: logger, endpoint: NetworkComposition.demoURL)
                    .id(source)
                Text("Swap an input above.\nThe receiver keeps the same contract.")
                    .font(.subheadline).foregroundStyle(PatchboardStyle.secondary)
                Rectangle().fill(PatchboardStyle.rule).frame(height: 1).accessibilityHidden(true)
                PatchboardStyle.label("JB / SWIFT STUDIES     ·     PATCHBOARD")
            }
            .padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .clipped().background(PatchboardStyle.paper).foregroundStyle(PatchboardStyle.ink)
    }

    private var sourcePicker: some View {
        let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            ForEach(DemoSource.allCases) { input in
                Button { source = input } label: {
                    VStack(spacing: 12) {
                        Image(systemName: source == input ? "circle.inset.filled" : "circle")
                        Text(input.rawValue).font(.system(.subheadline, design: .monospaced))
                    }
                    .padding(.vertical, 12).frame(maxWidth: .infinity)
                    .foregroundStyle(source == input ? PatchboardStyle.paper : PatchboardStyle.ink)
                    .background(source == input ? PatchboardStyle.ink : .clear)
                    .overlay(Rectangle().stroke(PatchboardStyle.ink, lineWidth: 1))
                }.buttonStyle(.plain).accessibilityIdentifier("source-\(input.rawValue)")
                    .accessibilityValue(source == input ? "Selected" : "Not selected")
            }
        }
    }
}

#Preview { NetworkLabView() }
