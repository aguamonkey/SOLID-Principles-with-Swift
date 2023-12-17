//
//  AngelHierarchy.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation

struct AngelHierarchy {
    var rank: String
    var angels: [AngelModel]

    // Method to describe the hierarchy. This keeps hierarchy-related logic within this model.
    func describeHierarchy() -> String {
        return "Hierarchy: \(rank) with \(angels.count) angels."
    }
}
