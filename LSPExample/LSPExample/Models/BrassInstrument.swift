//
//  BrassInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// A protocol conformer: it fulfils Playable without an Instrument superclass.

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

