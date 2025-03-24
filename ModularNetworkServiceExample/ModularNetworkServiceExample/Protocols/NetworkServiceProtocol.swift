//
//  NetworkServiceProtocol.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

protocol NetworkServiceProtocol {
    /// Asynchronously fetches data from the given URL.
    /// - Parameter url: The URL to fetch data from.
    /// - Returns: The data fetched from the URL.
    /// - Throws: An error if the request fails.
    func fetchData(from url: URL) async throws -> Data
}
