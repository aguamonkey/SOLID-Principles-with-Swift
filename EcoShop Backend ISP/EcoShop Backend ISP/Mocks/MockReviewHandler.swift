//
//  MockReviewHandler.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// Review previews stay small because this mock only models review behavior.
class MockReviewHandler: ReviewHandling {
    private var mockReviews: [Review] = ShopSamples.reviews
    
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
