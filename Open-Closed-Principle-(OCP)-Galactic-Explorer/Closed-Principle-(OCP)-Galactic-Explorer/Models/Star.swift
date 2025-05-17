//
//  Star.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI
// Models/Star.swift

// Star is another subclass of SpaceEntity, demonstrating the extendibility of the base class.

/// Star entity.
public class Star: SpaceEntity {
    public let name: String
    public let description: String
    public let type: String

    public init(name: String, description: String, type: String) {
        self.name = name
        self.description = description
        self.type = type
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.type = try container.decode(String.self, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, type
    }

    public func makeView() -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text("Star: \(name)")
                Text("Type: \(type)")
            }
            .padding()
        )
    }
}

extension Star: Luminous {
    func luminosity() -> Double {
        // Mock implementation
        return 1.0 // Assuming Sun-like star for simplicity
    }
}

