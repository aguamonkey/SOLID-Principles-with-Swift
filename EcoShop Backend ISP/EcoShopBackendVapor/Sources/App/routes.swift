import Fluent
import Vapor

// func routes(_ app: Application) throws {
//     app.get { req async throws in
//         try await req.view.render("index", ["title": "Hello Vapor!"])
//     }

//     app.get("hello") { req async -> String in
//         "Hello, world!"
//     }

//     try app.register(collection: TodoController())
// }

import Vapor

func routes(_ app: Application) throws {
    let productController = ProductController()
    app.post("products", use: productController.create)

    // Define other routes for order and review management
}
