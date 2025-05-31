//
//  ReviewHandling.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 28/01/2024.
//

import Foundation

// INTERFACE SEGREGATION: Dedicated interface for review management
// Clients that only need review functionality don't need to know about products or orders
protocol ReviewHandling {
    func addReview(_ review: Review) async throws
    func updateReview(_ review: Review) async throws
    func deleteReview(_ reviewId: String) async throws
    func getReview(_ reviewId: String) async throws -> Review?
    func findAllReviews() async throws -> [Review]
}
