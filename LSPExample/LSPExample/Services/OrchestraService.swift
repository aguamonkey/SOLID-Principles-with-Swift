//
//  OrchestraService.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation
import Combine

// OrchestraService is responsible for managing a collection of instruments.
// It adheres to LSP by treating all instruments, regardless of their specific subclass, uniformly.

class OrchestraService: ObservableObject {
    @Published var instruments: [any Playable] = []

    func addInstrument(_ instrument: any Playable) {
        instruments.append(instrument)
    }

    func performConcert() -> [String] {
        instruments.map { $0.play() }
    }

    func tuneAll() -> [String] {
        instruments.compactMap { ($0 as? Tunable)?.tune() }
    }

    func blowAll() -> [String] {
        instruments.compactMap { ($0 as? Blowable)?.blow() }
    }
}
