//
//  BrassInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// Models/BrassInstrument.swift

// A subclass of Instrument representing brass instruments.
// Adheres to LSP by fulfilling the contract established by the Instrument class.

struct BrassInstrument: Playable, Tunable, Blowable {
    let id: UUID
    let name: String
    let valveCount: Int

    func play() -> String {
        return "\(name), with \(valveCount) valves, produces a rich, loud sound."
    }

    func tune() -> String {
        return "Tuning \(name): adjusting \(valveCount) valves for harmony."
    }

    func blow() -> String {
        return "Blowing into \(name) uses all \(valveCount) valves for that bold brass tone."
    }
}

