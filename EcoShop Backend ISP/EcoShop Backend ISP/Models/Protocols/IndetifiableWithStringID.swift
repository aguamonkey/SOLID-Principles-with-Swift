//
//  IndetifiableWithStringID.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// INTERFACE SEGREGATION: This protocol provides a focused contract for models with String IDs
// Instead of forcing all models to implement Identifiable with UUID, we create a specific protocol
protocol IdentifiableWithStringID: Identifiable {
    var id: String { get }
}

// This extension satisfies Identifiable's requirement
extension IdentifiableWithStringID {
    var id: String { id }
}
