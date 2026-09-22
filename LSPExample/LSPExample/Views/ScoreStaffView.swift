import SwiftUI

/// Decorative notation, not a transcription of the bundled sound samples.
/// The cue mark changes only when the conductor acts; it is not an audio playhead.
struct ScoreStaffView: View {
    let row: Int
    let isIncluded: Bool
    let cue: Int?

    var body: some View {
        Canvas { context, size in
            let left: CGFloat = 8
            let right = size.width - 8
            let top: CGFloat = 18
            let gap: CGFloat = 7
            var staff = Path()
            for line in 0..<5 {
                let y = top + CGFloat(line) * gap
                staff.move(to: CGPoint(x: left, y: y))
                staff.addLine(to: CGPoint(x: right, y: y))
            }
            staff.move(to: CGPoint(x: right, y: top))
            staff.addLine(to: CGPoint(x: right, y: top + gap * 4))
            context.stroke(staff, with: .color(RehearsalStyle.rule), lineWidth: 1)

            let pitches = [3, 2, 4, 1, 2]
            for note in 0..<5 {
                let x = left + 12 + (right - left - 24) * CGFloat(note) / 4
                let y = top + CGFloat(pitches[(note + row) % pitches.count]) * gap
                let head = Path(ellipseIn: CGRect(x: x - 4.5, y: y - 3, width: 9, height: 6))
                context.fill(head, with: .color(RehearsalStyle.ink))
                var stem = Path()
                stem.move(to: CGPoint(x: x + 4, y: y))
                stem.addLine(to: CGPoint(x: x + 4, y: y - 21))
                context.stroke(stem, with: .color(RehearsalStyle.ink), lineWidth: 1.3)
            }
            if let cue, isIncluded {
                let x = left + 12 + (right - left - 24) * CGFloat(cue % 5) / 4
                var mark = Path()
                mark.move(to: CGPoint(x: x, y: 1))
                mark.addLine(to: CGPoint(x: x, y: 58))
                context.stroke(mark, with: .color(RehearsalStyle.accent), lineWidth: 2)
            }
        }
        .frame(height: 60)
        .opacity(isIncluded ? 1 : 0.25)
        .accessibilityHidden(true)
    }
}
