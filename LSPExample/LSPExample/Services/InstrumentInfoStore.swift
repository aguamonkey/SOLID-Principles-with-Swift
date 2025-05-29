//
//  InstrumentInfoStore.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import Foundation

/// Loads instruments.json on app launch.
struct InstrumentInfoStore {
    static let all: [InstrumentInfo] = Bundle.main.decode("instruments.json")
}
