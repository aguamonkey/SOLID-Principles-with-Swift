import SwiftUI

struct ContentView: View {
    let dataService: DataServiceProtocol
    @State private var collection = Collection.angels
    @Environment(\.dynamicTypeSize) private var textSize
    private enum Collection: String, CaseIterable { case angels = "Angels", demons = "Demons" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                GuideHeader()
                collectionPicker
                if collection == .angels { AngelListView(dataService: dataService) }
                else { DemonListView(dataService: dataService) }
                GuideStyle.divider
                GuideStyle.label("JB / SWIFT STUDIES     ·     01")
                    .foregroundStyle(GuideStyle.secondary)
            }
            .padding(24).frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .clipped().background(GuideStyle.paper).foregroundStyle(GuideStyle.ink).tint(GuideStyle.annotation)
    }

    private var collectionPicker: some View {
        let layout = textSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 8)) : AnyLayout(HStackLayout(spacing: 8))
        return layout {
            ForEach(Collection.allCases, id: \.self) { item in
                Button { collection = item } label: {
                    Text(item.rawValue).font(.system(.subheadline, design: .monospaced))
                        .padding(15).frame(maxWidth: .infinity, minHeight: 48)
                        .background(collection == item ? GuideStyle.ink : .clear)
                        .foregroundStyle(collection == item ? GuideStyle.paper : GuideStyle.ink)
                        .overlay(Rectangle().stroke(GuideStyle.ink, lineWidth: 1))
                }.buttonStyle(.plain).accessibilityIdentifier("collection-\(item.rawValue)")
                    .accessibilityValue(collection == item ? "Selected" : "Not selected")
            }
        }
    }
}
