//
//  WindInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// Models/WindInstrument.swift

// A subclass of Instrument representing wind instruments.
// Follows LSP by being a proper substitute for the Instrument class.
class WindInstrument: Instrument {
    var reedType: String

    init(name: String, reedType: String) {
        self.reedType = reedType
        super.init(name: name)
    }

    // Overrides the play method with behavior specific to wind instruments.
    override func play() -> String {
        return "\(name), using a \(reedType) reed, produces melodious tunes."
    }

    // Specific method for wind instruments, showcasing unique behavior.
    func blow() -> String {
        return "\(name) is being played by blowing air through the \(reedType) reed."
    }
}

