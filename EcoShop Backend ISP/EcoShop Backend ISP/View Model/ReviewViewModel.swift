//
//  ReviewViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

// INTERFACE SEGREGATION: ReviewViewModel only knows about ReviewHandling
// This separation allows different implementations without affecting other parts
@MainActor
class ReviewViewModel: ObservableObject {
    private let reviewHandler: ReviewHandling // ISP: Single-purpose dependency
    
    @Published var reviews: [Review] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    init(reviewHandler: ReviewHandling) {
        self.reviewHandler = reviewHandler
    }
    
    func loadReviews() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedReviews = try await reviewHandler.findAllReviews()
            self.reviews = fetchedReviews
        } catch {
            errorMessage = "Failed to load reviews: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func addReview(_ review: Review) async {
        do {
            try await reviewHandler.addReview(review)
            await loadReviews()
        } catch {
            errorMessage = "Failed to add review: \(error.localizedDescription)"
        }
    }
    
    func updateReview(_ review: Review) async {
        do {
            try await reviewHandler.updateReview(review)
            await loadReviews()
        } catch {
            errorMessage = "Failed to update review: \(error.localizedDescription)"
        }
    }
    
    func deleteReview(_ reviewId: String) async {
        do {
            try await reviewHandler.deleteReview(reviewId)
            await loadReviews()
        } catch {
            errorMessage = "Failed to delete review: \(error.localizedDescription)"
        }
    }
}
