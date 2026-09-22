//
//  Planet.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation
import SwiftUI

// Models/Planet.swift

// Planet supplies its decoding and presentation through the SpaceEntity contract.
/// Planet entity.
public class Planet: SpaceEntity {
    public let id = UUID()
    public let name: String
    public let description: String
    public let numberOfMoons: Int

    public init(name: String, description: String, numberOfMoons: Int) {
        self.name = name
        self.description = description
        self.numberOfMoons = numberOfMoons
    }

    // Custom decoding via factory (see below)
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.numberOfMoons = try container.decode(Int.self, forKey: .numberOfMoons)
    }

    private enum CodingKeys: String, CodingKey {
        case name, description, numberOfMoons
    }

    /// Custom view for planets
    public func makeView() -> AnyView {
        AnyView(AtlasFactView(label: "SATELLITES", value: "\(numberOfMoons) moon\(numberOfMoons == 1 ? "" : "s")"))
    }
}
