//
//  SpaceEntityProtocols.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import Foundation

// Models/SpaceEntityProtocols.swift

// This file contains all protocols related to space entities.
// It's part of the project's adherence to the Open/Closed Principle by allowing
// the extension of functionalities through protocols without modifying existing classes.

protocol Orbitable {
    func orbitPath() -> String
}

protocol Luminous {
    func luminosity() -> Double
}

// Additional protocols can be defined here as the project grows.
