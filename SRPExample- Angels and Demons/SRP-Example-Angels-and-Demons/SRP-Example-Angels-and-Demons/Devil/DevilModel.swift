//
//  DevilModel.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

// DemonModel encapsulates all data and behaviors specific to a Demon, separate from the UI."

import Foundation

struct DemonModel {
    var name: String
    var ability: String

    // This function is specific to a Demon, describing its unique ability.
    func describeAbility() -> String {
        return "\(name) wields the ability of \(ability)."
    }
}
