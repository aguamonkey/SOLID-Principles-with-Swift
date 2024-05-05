//
//  ReviewViewModel.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import Foundation

class ReviewViewModel: ObservableObject {
    private let reviewHandler: ReviewHandling

    @Published var reviews: [Review] = []

    init(reviewHandler: ReviewHandling) {
        self.reviewHandler = reviewHandler
    }

    func loadReviews() async {
        let fetchedReviews = await reviewHandler.findAllReviews()
        DispatchQueue.main.async {
            self.reviews = fetchedReviews
        }
    }

    func addReview(_ review: Review) {
        reviewHandler.addReview(review)
        Task {
            await loadReviews()
        }
    }

    func updateReview(_ review: Review) {
        reviewHandler.updateReview(review)
        Task {
            await loadReviews()
        }
    }

    func deleteReview(_ reviewId: String) {
        reviewHandler.deleteReview(reviewId)
        Task {
            await loadReviews()
        }
    }
}

