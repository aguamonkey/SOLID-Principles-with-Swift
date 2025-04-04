//
//  DevilHierarchy.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation

struct DemonHierarchy {
    var rank: String
    var demons: [DemonModel]
    
    func describeHierarchy() -> String {
        return "Hierarchy: \(rank) with \(demons.count) demons."
    }
}
