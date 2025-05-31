//
//  MockReviewHandler.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// INTERFACE SEGREGATION: Dedicated mock for review handling
class MockReviewHandler: ReviewHandling {
    private var mockReviews: [Review] = [
        Review(id: "1", productId: "1", title: "Great Phone!", content: "Love this iPhone", rating: 5),
        Review(id: "2", productId: "2", title: "Powerful Machine", content: "Best laptop ever", rating: 4)
    ]
    
    func addReview(_ review: Review) async throws {
        mockReviews.append(review)
    }
    
    func updateReview(_ review: Review) async throws {
        if let index = mockReviews.firstIndex(where: { $0.id == review.id }) {
            mockReviews[index] = review
        }
    }
    
    func deleteReview(_ reviewId: String) async throws {
        mockReviews.removeAll { $0.id == reviewId }
    }
    
    func getReview(_ reviewId: String) async throws -> Review? {
        return mockReviews.first { $0.id == reviewId }
    }
    
    func findAllReviews() async throws -> [Review] {
        return mockReviews
    }
}
