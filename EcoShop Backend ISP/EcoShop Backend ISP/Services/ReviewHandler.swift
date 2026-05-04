//
//  ReviewHandler.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// Review storage concerns remain separate from ordering and product editing.
class ReviewHandler: ReviewHandling {
    private var reviews: [Review] = []
    
    func addReview(_ review: Review) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        reviews.append(review)
    }
    
    func updateReview(_ review: Review) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        if let index = reviews.firstIndex(where: { $0.id == review.id }) {
            reviews[index] = review
        } else {
            throw ReviewError.notFound
        }
    }
    
    func deleteReview(_ reviewId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        reviews.removeAll { $0.id == reviewId }
    }
    
    func getReview(_ reviewId: String) async throws -> Review? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return reviews.first { $0.id == reviewId }
    }
    
    func findAllReviews() async throws -> [Review] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return reviews
    }
}

enum ReviewError: LocalizedError {
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Review not found"
        }
    }
}
