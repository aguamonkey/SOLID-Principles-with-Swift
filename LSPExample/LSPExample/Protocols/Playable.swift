//
//  Playable.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import Foundation

protocol Playable {
    var id: UUID { get }
    func play() -> String
}
