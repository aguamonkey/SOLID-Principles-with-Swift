import SwiftUI

enum PatchboardStyle {
    static let paper = adaptive(0xECEDE7, 0x242724)
    static let ink = adaptive(0x232C28, 0xE8EEE6)
    static let secondary = adaptive(0x59645C, 0xB5C3B7)
    static let rule = adaptive(0xBFC8BC, 0x526055)
    static let accent = adaptive(0xA23D23, 0xFFAF8D)
    static let terminal = Color(red: 0.08, green: 0.14, blue: 0.12)
    static let signal = Color(red: 0.8, green: 0.94, blue: 0.61)
    static func label(_ value: String) -> some View {
        Text(value).font(.system(.caption, design: .monospaced)).tracking(1)
            .fixedSize(horizontal: false, vertical: true)
    }
    private static func adaptive(_ light: UInt, _ dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                           green: CGFloat((hex >> 8) & 255) / 255,
                           blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
}

struct PatchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.headline, design: .monospaced))
            .padding(18).frame(maxWidth: .infinity, minHeight: 54)
            .background(PatchboardStyle.ink).foregroundStyle(PatchboardStyle.paper)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct PatchCable: View {
    let input: Int
    var body: some View {
        VStack(spacing: 0) {
            Canvas { context, size in
                let start = CGFloat(input * 2 + 1) * size.width / 6
                var wire = Path()
                wire.move(to: CGPoint(x: start, y: 0))
                wire.addLine(to: CGPoint(x: start, y: 18))
                wire.addCurve(to: CGPoint(x: size.width / 2, y: 55),
                              control1: CGPoint(x: start, y: 45), control2: CGPoint(x: size.width / 2, y: 20))
                context.stroke(wire, with: .color(PatchboardStyle.accent), lineWidth: 3)
            }.frame(height: 55)
            PatchboardStyle.label("NetworkRepositoryProtocol")
                .padding(14).frame(maxWidth: .infinity)
                .overlay(Rectangle().stroke(PatchboardStyle.ink, lineWidth: 1))
            Rectangle().fill(PatchboardStyle.ink).frame(width: 2, height: 24)
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel("Selected input connects through the repository contract to the receiver")
    }
}
