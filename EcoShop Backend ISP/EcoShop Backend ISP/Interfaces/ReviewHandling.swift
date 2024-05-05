//
//  ReviewHandling.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Interfaces/ReviewHandling.swift

/// The directive for managing the chorus of customer voices, an integral part of President Principle's democratic vision.
/// This interface ensures that every critique and commendation is heard loud and clear.
protocol ReviewHandling {
    func addReview(_ review: Review)
    func updateReview(_ review: Review)
    func deleteReview(_ reviewId: String)
    func getReview(_ reviewId: String) -> Review?
    func findAllReviews() async -> [Review]
}
