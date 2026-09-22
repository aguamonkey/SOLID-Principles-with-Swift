import SwiftUI

/// Displays the responses returned by the concert, rather than calling play() on
/// every SwiftUI redraw. Each explicit conductor action produces one report.
struct OrchestraPerformanceView: View {
    let responses: [String]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RehearsalStyle.label("THE ENSEMBLE RESPONDS")
                .foregroundStyle(RehearsalStyle.accent)
            ForEach(Array(responses.enumerated()), id: \.offset) { index, response in
                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
                layout {
                    RehearsalStyle.label(String(format: "%02d", index + 1))
                        .foregroundStyle(RehearsalStyle.accent)
                    Text(response)
                        .font(.system(.subheadline, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("response.\(index)")
                }
                .accessibilityElement(children: .contain)
            }
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
