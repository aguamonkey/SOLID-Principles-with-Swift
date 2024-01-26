import Fluent
import Vapor

final class Product: Model, Content {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "price")
    var price: Double

    init() { }

    init(id: UUID? = nil, name: String, description: String, price: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price  // Corrected from 'this' to 'self'
    }
}

