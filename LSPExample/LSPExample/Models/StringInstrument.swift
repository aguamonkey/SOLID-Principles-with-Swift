//
//  StringInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//


import Foundation

struct StringInstrument: Playable, Tunable {
    let id: UUID
    let name: String

    func play() -> String {
        return "\(name), a string instrument, is playing melodious tunes."
    }

    func tune() -> String {
        return "Tuning \(name): tightening strings for perfect pitch."
    }
}
