import Vapor

struct ProductController {
    func create(req: Request) throws -> EventLoopFuture<Product> {
        let product = try req.content.decode(Product.self)
        return product.save(on: req.db).map { product }
    }

    // Other CRUD operations (read, update, delete)
}
