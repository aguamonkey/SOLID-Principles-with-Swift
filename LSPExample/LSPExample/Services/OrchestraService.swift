//
//  OrchestraService.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation
import Combine

// Services/OrchestraService.swift

// OrchestraService is responsible for managing a collection of instruments.
// It adheres to LSP by treating all instruments, regardless of their specific subclass, uniformly.

class OrchestraService: ObservableObject {
    @Published var instruments: [Instrument] = []

    // Adds an instrument to the orchestra
    func addInstrument(_ instrument: Instrument) {
        instruments.append(instrument)
    }

    // Simulates tuning all instruments in the orchestra
    func tuneInstruments() -> String {
        // Simulating tuning for each instrument
        let tuningResults = instruments.map { "\($0.name) is being tuned." }
        return tuningResults.joined(separator: "\n")
    }

    // Organizes a concert with a specific sequence of instrument play
    func organizeConcert(withSequence sequence: [Instrument]) -> String {
        // Simulating a concert based on the given sequence
        let concertPerformance = sequence.map { $0.play() }
        return concertPerformance.joined(separator: "\n")
    }

    // Simulates an entire concert
    func performConcert() -> [String] {
        return instruments.map { $0.play() }
    }

    // Additional orchestral management functions can be added here
}
