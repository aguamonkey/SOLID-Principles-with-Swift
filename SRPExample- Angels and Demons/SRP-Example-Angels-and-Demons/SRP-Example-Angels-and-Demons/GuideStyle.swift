import SwiftUI

enum GuideStyle {
    static let paper = adaptive(0xF5F0E6, 0x25211E)
    static let ink = adaptive(0x302A25, 0xF3EADD)
    static let secondary = adaptive(0x6C6055, 0xC7B8A8)
    static let annotation = adaptive(0xA5392B, 0xFFAD91)
    static let rule = adaptive(0xD1C3B0, 0x645448)
    static func label(_ text: String) -> some View {
        Text(text).font(.system(.caption, design: .monospaced)).tracking(1)
            .fixedSize(horizontal: false, vertical: true)
    }
    static var divider: some View { Rectangle().fill(rule).frame(height: 1).accessibilityHidden(true) }
    private static func adaptive(_ light: UInt, _ dark: UInt) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                           green: CGFloat((hex >> 8) & 255) / 255,
                           blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
}

struct GuideHeader: View {
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 48
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { GuideStyle.label("A FIELD GUIDE"); Spacer(); GuideStyle.label("VOL. I") }
            GuideStyle.divider
            (Text("Angels\n") + Text("&").foregroundColor(GuideStyle.annotation) + Text(" Demons")).font(.system(size: titleSize, weight: .regular, design: .serif))
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            Text("An index of powers, figures,\nand the orders they belong to.")
                .font(.system(.subheadline, design: .serif)).foregroundStyle(GuideStyle.secondary)
        }
    }
}

struct GuidePlate: View {
    let name: String
    let attribute: String
    let description: String
    let symbol: String
    @ScaledMetric(relativeTo: .largeTitle) private var nameSize = 38
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12)) : AnyLayout(HStackLayout(alignment: .center, spacing: 12))
            layout {
                VStack(alignment: .leading, spacing: 9) {
                    Text(name).font(.system(size: nameSize, weight: .regular, design: .serif))
                        .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                    GuideStyle.label(attribute.uppercased()).foregroundStyle(GuideStyle.annotation)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: symbol).font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(GuideStyle.annotation).accessibilityHidden(true)
            }
            Text(description).font(.system(.body, design: .serif))
                .fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("figure-description")
        }
        .padding(.vertical, 10)
    }
}

struct GuideEntry: View {
    let name: String
    let attribute: String
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(name).font(.system(.title3, design: .serif))
            GuideStyle.label(attribute).foregroundStyle(GuideStyle.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
    }
}

struct GuideNotice: View {
    let message: String
    var retry: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(message).font(.system(.body, design: .serif))
            if let retry { Button("Open the index again", action: retry).buttonStyle(.bordered).accessibilityIdentifier("retry-index") }
        }.padding(18).frame(maxWidth: .infinity, alignment: .leading)
            .background(GuideStyle.rule.opacity(0.22))
            .overlay(alignment: .leading) { Rectangle().fill(GuideStyle.annotation).frame(width: 2) }
    }
}
