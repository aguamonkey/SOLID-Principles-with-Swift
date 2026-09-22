import SwiftUI

/// A schematic index, not physical orbital data. Placement depends on collection order,
/// so new SpaceEntity conformers appear without another rendering branch.
struct OrbitalMapView: View {
    let entities: [any SpaceEntity]
    let selectedID: UUID?
    let onSelect: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    grid(in: geometry.size)
                    orbits(in: geometry.size)
                    ForEach(Array(entities.enumerated()), id: \.element.id) { index, entity in
                        marker(entity, index: index)
                            .position(position(for: index, in: geometry.size))
                    }
                    VStack {
                        HStack {
                            AtlasStyle.caption("N ↑")
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            AtlasStyle.caption("SCHEMATIC / NOT TO SCALE")
                                .padding(.vertical, 4)
                                .background(AtlasStyle.paper.opacity(0.95))
                            Spacer()
                        }
                    }
                    .padding(18)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
            .frame(height: 236)
            .clipped()

            HStack {
                AtlasStyle.caption("OBSERVATION SHEET")
                Spacer()
                AtlasStyle.caption(String(format: "INDEX %02d", entities.count))
            }
            .foregroundStyle(AtlasStyle.secondary)
            .padding(.horizontal, 18)
            .padding(.bottom, 12)
        }
        .foregroundStyle(AtlasStyle.ink)
        .overlay(alignment: .top) { AtlasStyle.divider }
        .overlay(alignment: .bottom) { AtlasStyle.divider }
    }

    private func marker(_ entity: any SpaceEntity, index: Int) -> some View {
        let isSelected = entity.id == selectedID
        return Button {
            onSelect(entity.id)
        } label: {
            ZStack {
                Circle()
                    .stroke(isSelected ? AtlasStyle.accent : .clear, lineWidth: 1)
                    .frame(width: 30, height: 30)
                Circle()
                    .fill(isSelected ? AtlasStyle.accent : AtlasStyle.ink)
                    .frame(width: 10, height: 10)
                Text(String(format: "%02d", index + 1))
                    .font(.system(size: 12, design: .monospaced))
                    .offset(x: 17, y: -22)
            }
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select \(entity.name) on the map")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func position(for index: Int, in size: CGSize) -> CGPoint {
        // Golden-angle spacing gives every added entry a position with no type lookup.
        let angle = (Double(index) * 137.5 - 55) * .pi / 180
        let radius = 0.24 + Double(index % 3) * 0.08
        return CGPoint(
            x: size.width / 2 + cos(angle) * size.width * radius,
            y: size.height / 2 + sin(angle) * size.height * radius * 0.78
        )
    }

    private func grid(in size: CGSize) -> some View {
        Path { path in
            for x in stride(from: CGFloat(0), through: size.width, by: 38) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: CGFloat(0), through: size.height, by: 38) {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
        }
        .stroke(AtlasStyle.rule.opacity(0.4), lineWidth: 0.5)
        .accessibilityHidden(true)
    }

    private func orbits(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<3) { index in
                Ellipse()
                    .stroke(AtlasStyle.ink.opacity(0.3), lineWidth: 0.8)
                    .frame(width: size.width * (0.34 + Double(index) * 0.24),
                           height: size.height * (0.34 + Double(index) * 0.2))
                    .rotationEffect(.degrees(-24))
            }
        }
        .frame(width: size.width, height: size.height)
        .accessibilityHidden(true)
    }
}
