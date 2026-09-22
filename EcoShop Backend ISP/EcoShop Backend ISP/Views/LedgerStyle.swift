import SwiftUI

enum LedgerStyle {
    static let paper = adaptive(0xF5F1E5, 0x242820)
    static let ink = adaptive(0x243D30, 0xE9EFDF)
    static let secondary = adaptive(0x646A58, 0xB8C4AC)
    static let rule = adaptive(0xC8CCB9, 0x52604A)
    static let accent = adaptive(0x8B432B, 0xF1B190)
    static let currency = "GBP"
    static var divider: some View { Rectangle().fill(rule).frame(height: 1).accessibilityHidden(true) }
    static func label(_ text: String) -> some View {
        Text(text).font(.system(.caption, design: .monospaced))
            .tracking(1).fixedSize(horizontal: false, vertical: true)
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

struct LedgerPage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 44

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    LedgerStyle.label("ECOSHOP / GOODS, SIMPLY.")
                    Spacer()
                    Image(systemName: "leaf").font(.title2).accessibilityHidden(true)
                }
                .foregroundStyle(LedgerStyle.ink)
                LedgerStyle.divider
                Text(title).font(.system(size: titleSize, weight: .regular, design: .serif))
                    .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
                Text(subtitle).font(.subheadline).foregroundStyle(LedgerStyle.secondary)
                content
                LedgerStyle.divider
                LedgerStyle.label("JB / SWIFT STUDIES     ·     04")
                    .foregroundStyle(LedgerStyle.secondary).padding(.vertical, 6)
            }
            .padding(24).frame(maxWidth: 660).frame(maxWidth: .infinity)
        }
        .clipped()
        .background(LedgerStyle.paper)
        .foregroundStyle(LedgerStyle.ink)
        .tint(LedgerStyle.ink)
    }
}

struct LedgerButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.subheadline, design: .monospaced))
            .padding(16).frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(LedgerStyle.paper).background(LedgerStyle.ink)
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}

struct LedgerNotice: View {
    let message: String
    var retry: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message).fixedSize(horizontal: false, vertical: true)
            if let retry { Button("Try again", action: retry).buttonStyle(.bordered) }
        }
        .font(.subheadline).padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) { Rectangle().fill(LedgerStyle.accent).frame(width: 3) }
        .background(LedgerStyle.rule.opacity(0.2))
    }
}

struct ProductLedgerRow: View {
    let product: Product
    let number: Int
    @Environment(\.dynamicTypeSize) private var textSize
    var body: some View {
        let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10)) : AnyLayout(HStackLayout(alignment: .top, spacing: 14))
        layout {
            Text(String(format: "%02d", number)).font(.system(.caption, design: .monospaced))
                .foregroundStyle(LedgerStyle.secondary).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 7) {
                Text(product.name).font(.system(.title3, design: .serif))
                Text(product.description).font(.subheadline).foregroundStyle(LedgerStyle.secondary)
                Text("REF / \(product.id)").font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(LedgerStyle.secondary).lineLimit(1)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Text(product.price, format: .currency(code: LedgerStyle.currency))
                .font(.system(.subheadline, design: .monospaced)).fixedSize()
        }
        .padding(.vertical, 18)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("product-\(product.id)")
        LedgerStyle.divider
    }
}
