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
class BrassInstrument: Instrument {
    var valveCount: Int

    init(name: String, valveCount: Int) {
        self.valveCount = valveCount
        super.init(name: name)
    }

    // Overrides the play method with behavior specific to brass instruments.
    override func play() -> String {
        return "\(name), with \(valveCount) valves, produces a rich, loud sound."
    }
    
    // Specific method for brass instruments, demonstrating unique behavior while maintaining LSP.
    func blow() -> String {
        return "\(name) is being blown, utilizing its \(valveCount) valves."
    }
}

