//
//  ReviewHandling.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// Review clients can stay isolated from catalog and checkout workflows.
protocol ReviewHandling {
    func addReview(_ review: Review) async throws
    func updateReview(_ review: Review) async throws
    func deleteReview(_ reviewId: String) async throws
    func getReview(_ reviewId: String) async throws -> Review?
    func findAllReviews() async throws -> [Review]
}
