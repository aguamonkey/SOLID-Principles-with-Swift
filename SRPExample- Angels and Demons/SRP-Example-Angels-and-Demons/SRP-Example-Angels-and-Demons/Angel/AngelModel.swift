//
//  AngelModel.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation

// AngelModel is responsible for representing the data and behavior of an Angel.
// It adheres to the Single Responsibility Principle by focusing solely on angel-related data and logic.

struct AngelModel {
    var name: String
    var power: String

    // Functionality specific to an Angel can be added here.
    // For example, a function to describe the Angel's power.
    func describePower() -> String {
        return "\(name) possesses the power of \(power)."
    }
}
