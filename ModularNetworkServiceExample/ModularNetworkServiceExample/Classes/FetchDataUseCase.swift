//
//  FetchDataUseCase.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

// The use case that depends on a public protocol.
public class FetchDataUseCase {
    private let networkService: NetworkServiceProtocol
    
    // Ensure the parameter type is public.
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    /// Executes the use case to fetch data from the provided URL.
    public func execute(url: URL) async throws -> Data {
        return try await networkService.fetchData(from: url)
    }
}
