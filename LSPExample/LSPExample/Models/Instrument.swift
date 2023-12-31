//
//  Instrument.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// Models/Instrument.swift

// The base class for all instruments in the orchestra.
// Defines a general contract (play method) for all specific instrument classes.
class Instrument: Identifiable {
    let id = UUID()
    var name: String

    init(name: String) {
        self.name = name
    }

    // A method that every instrument subclass should implement, showcasing its play style.
    func play() -> String {
        return "\(name) is playing its unique sound."
    }
}

