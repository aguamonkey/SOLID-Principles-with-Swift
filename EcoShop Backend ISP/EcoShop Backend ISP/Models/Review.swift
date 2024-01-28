//
//  Review.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Models/Review.swift

/// A model representing a customer review of a product.
/// Consider this as feedback from the citizens on the goods and services provided.
struct Review: IdentifiableWithStringID {
    var id: String        // Each review has a unique ID, like a reference number.
    var productId: String // The product under review, similar to a topic under discussion.
    var title: String     // The title of the review, giving a quick overview, like a headline.
    var content: String   // Detailed feedback, the body of the review.
    var rating: Int       // The rating given to the product, reflecting public opinion.

    // Reviews adhere to President Principle's decree: only contain what's needed for the purpose of critique.
}
