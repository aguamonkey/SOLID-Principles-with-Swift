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
    
    // Encapsulates hierarchy-related logic.
    func describeHierarchy() -> String {
        return "Hierarchy: \(rank) with \(angels.count) angels."
    }
}
