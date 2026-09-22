import SwiftUI

enum RehearsalStyle {
    static let paper = adaptive(light: 0xF6F3EC, dark: 0x24221E)
    static let ink = adaptive(light: 0x26251F, dark: 0xF3EDDD)
    static let secondary = adaptive(light: 0x6E6958, dark: 0xC2BCA8)
    static let rule = adaptive(light: 0xD2CCBA, dark: 0x555044)
    static let accent = adaptive(light: 0xB74226, dark: 0xFFAA79)

    static var divider: some View {
        Rectangle().fill(rule).frame(height: 1).accessibilityHidden(true)
    }

    static func label(_ text: String) -> some View {
        Text(text).font(.system(.caption2, design: .monospaced))
            .tracking(1.1).fixedSize(horizontal: false, vertical: true)
    }

    private static func adaptive(light: UInt, dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                           green: CGFloat((hex >> 8) & 255) / 255,
                           blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
}

struct ConductorButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .monospaced))
            .padding(18).frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(RehearsalStyle.paper)
            .background(RehearsalStyle.ink)
            .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.4)
    }
}
