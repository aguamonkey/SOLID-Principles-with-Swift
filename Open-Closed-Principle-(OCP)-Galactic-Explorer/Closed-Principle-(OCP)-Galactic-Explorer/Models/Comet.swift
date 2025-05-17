//
//  Comet.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI

/// Comet entity.
public class Comet: SpaceEntity {
    public let name: String
    public let description: String
    public let tailLength: Double

    public init(name: String, description: String, tailLength: Double) {
        self.name = name
        self.description = description
        self.tailLength = tailLength
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.tailLength = try container.decode(Double.self, forKey: .tailLength)
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, tailLength
    }

    public func makeView() -> AnyView {
        AnyView(
            VStack(alignment: .leading) {
                Text("Comet: \(name)")
                Text("Tail: \(tailLength) km")
            }
            .padding()
        )
    }
}
