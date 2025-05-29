//
//  Bundle+Decodable.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import Foundation

import Foundation

extension Bundle {
    /// Decode a JSON file from the main bundle into a Decodable type.
    func decode<T: Decodable>(_ filename: String) -> T {
        guard let url = self.url(forResource: filename, withExtension: nil) else {
            fatalError("📦 Failed to locate \(filename) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("📦 Failed to load \(filename) from bundle.")
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("📦 Failed to decode \(filename): \(error)")
        }
    }
}
