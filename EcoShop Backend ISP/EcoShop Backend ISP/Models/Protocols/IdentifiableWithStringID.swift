//
//  IdentifiableWithStringID.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 31/05/2025.
//

import Foundation

// Shared list models use string identifiers without forcing a UUID-based shape.
protocol IdentifiableWithStringID: Identifiable {
    var id: String { get }
}

// This extension satisfies Identifiable's requirement
extension IdentifiableWithStringID {
    var id: String { id }
}
