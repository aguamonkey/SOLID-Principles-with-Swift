//
//  StringInstrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// Models/StringInstrument.swift

// A subclass of Instrument representing string instruments.
class StringInstrument: Instrument {
    // Additional properties and methods specific to string instruments can be added here.

    override func play() -> String {
        return "\(name), a string instrument, is playing melodious tunes."
    }
}
