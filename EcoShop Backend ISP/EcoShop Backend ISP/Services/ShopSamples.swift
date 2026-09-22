import Foundation

/// Deterministic demo content, not sustainability certifications or a live shop.
enum ShopSamples {
    static let products = [
        Product(id: "EC-01", name: "Market tote", description: "Unbleached cotton / made for the weekly shop", price: 14),
        Product(id: "EC-02", name: "Travel cup", description: "Brushed steel / take the long way home", price: 22),
        Product(id: "EC-03", name: "Kitchen cloths", description: "A set of three / wash, dry, repeat", price: 9)
    ]
    static let orders = [Order(id: "ORD-001", productIds: ["EC-01", "EC-03"],
                               orderDate: Date(timeIntervalSince1970: 1789948800), totalAmount: 23)]
    static let reviews = [Review(id: "REV-001", productId: "EC-01", title: "Always by the door",
                                 content: "A good size for the market. Folds into my coat pocket on the way there.", rating: 5)]
}
