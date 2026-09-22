import SwiftUI

/// Ink and paper respond to system appearance; text follows Dynamic Type.
enum AtlasStyle {
    static let paper = adaptive(light: 0xECEBDF, dark: 0x172225)
    static let ink = adaptive(light: 0x1D4145, dark: 0xD7E9DB)
    static let secondary = adaptive(light: 0x4D6C6C, dark: 0xA0BCB4)
    static let rule = adaptive(light: 0xB7C7BF, dark: 0x3F5956)
    static let accent = adaptive(light: 0xA4432E, dark: 0xF59B78)

    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .tracking(1.4)
            .fixedSize(horizontal: false, vertical: true)
    }

    static var divider: some View {
        Rectangle().fill(rule).frame(height: 1).accessibilityHidden(true)
    }

    private static func adaptive(light: UInt, dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 255) / 255,
                green: CGFloat((hex >> 8) & 255) / 255,
                blue: CGFloat(hex & 255) / 255,
                alpha: 1
            )
        })
    }
}

/// Entity-owned details use the atlas typography without the atlas knowing their type.
struct AtlasFactView: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AtlasStyle.caption(label).foregroundStyle(AtlasStyle.secondary)
            Text(value).font(.system(.subheadline, design: .monospaced))
        }
        .foregroundStyle(AtlasStyle.ink)
        .accessibilityElement(children: .combine)
    }
}

struct AtlasActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .monospaced))
            .padding(.horizontal, 18)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(AtlasStyle.paper)
            .background(AtlasStyle.ink)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
