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
    // Add a new voice to the chorus, welcoming a fresh review to the assembly.
    func addReview(_ review: Review)
    
    // Refine the words of a review, ensuring clarity and fairness in the message.
    func updateReview(_ review: Review)
    
    // Remove a review from the public record, when it's time to lower the curtain.
    func deleteReview(_ reviewId: String)
    
    // Highlight a particular review, allowing its message to resonate with the audience.
    func getReview(_ reviewId: String) -> Review?
}
