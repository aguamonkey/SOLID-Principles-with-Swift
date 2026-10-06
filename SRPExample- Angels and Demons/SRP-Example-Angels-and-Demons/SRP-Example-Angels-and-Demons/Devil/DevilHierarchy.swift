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
        let noun = demons.count == 1 ? "demon" : "demons"
        return "Hierarchy: \(rank) with \(demons.count) \(noun)."
    }
}
