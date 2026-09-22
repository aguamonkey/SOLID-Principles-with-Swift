import SwiftUI

struct InstrumentRowView: View {
    let info: InstrumentInfo
    let row: Int
    let isIncluded: Bool
    let cue: Int?
    let toggle: () -> Void
    let preview: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 0) {
            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
                : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
            layout {
                Button(action: toggle) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(info.name).font(.system(.headline, design: .serif))
                        RehearsalStyle.label(isIncluded ? "● IN ENSEMBLE" : "○ RESTING")
                            .foregroundStyle(RehearsalStyle.accent)
                    }
                    .frame(minWidth: 90, minHeight: 52, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("instrument.\(info.name)")
                .accessibilityLabel(info.name)
                .accessibilityValue(isIncluded ? "In ensemble" : "Resting")
                .accessibilityHint("Double tap to \(isIncluded ? "rest" : "include") this instrument")
                ScoreStaffView(row: row, isIncluded: isIncluded, cue: cue)
                    .frame(maxWidth: .infinity)
                Button(action: preview) {
                    Image(systemName: "speaker.wave.2")
                        .frame(width: 44, height: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(RehearsalStyle.secondary)
                .accessibilityLabel("Preview \(info.name) audio")
            }
            .padding(.vertical, 6)
            RehearsalStyle.divider
        }
    }
}
