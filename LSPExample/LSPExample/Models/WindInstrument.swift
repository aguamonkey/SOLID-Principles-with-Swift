//
//  WindInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

struct WindInstrument: Playable, Tunable, Blowable {
    let id: UUID
    let name: String
    let reedType: String

    func play() -> String {
        return "\(name), using a \(reedType) reed, produces melodious tunes."
    }

    func tune() -> String {
        return "Tuning \(name): refining the \(reedType) reed's response."
    }

    func blow() -> String {
        return "Blowing into \(name) involves air flow through the \(reedType) reed."
    }
}
