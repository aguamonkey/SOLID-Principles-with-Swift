//
//  SpaceEntity.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI

// MARK: - 1. Base Protocol for Space Entities

/// All space entities conform to this protocol.
/// OCP: Open for extension via new types conforming; Closed for modification of existing behavior.
public protocol SpaceEntity: Codable, Identifiable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
    /// Provides a type-erased SwiftUI view for this entity.
    /// OCP: New entity types supply their own view without editing consumers.
    func makeView() -> AnyView
}

public extension SpaceEntity {
    // Default unique id
    var id: UUID { UUID() }
    
    // Default view shows basic info; can be overridden.
    func makeView() -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text("Name: \(name)")
                Text("Description: \(description)")
            }
            .padding()
        )
    }
}
