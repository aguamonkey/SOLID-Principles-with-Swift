//
//  NetworkServiceProtocol.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

// Make sure this is public if used in a public API.
public protocol NetworkServiceProtocol {
    /// Asynchronously fetches data from the given URL.
    /// - Parameter url: The URL to fetch data from.
    /// - Returns: The data fetched from the URL.
    /// - Throws: A DataError if the request fails.
    func fetchData(from url: URL) async throws -> Data
}
