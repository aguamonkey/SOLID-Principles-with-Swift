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
    let soundSource: String

    func play() -> String {
        return "\(name), using \(soundSource), produces melodious tunes."
    }

    func tune() -> String {
        return "Tuning \(name): adjusting the air column for pitch."
    }

    func blow() -> String {
        return "Blowing into \(name) uses \(soundSource)."
    }
}
