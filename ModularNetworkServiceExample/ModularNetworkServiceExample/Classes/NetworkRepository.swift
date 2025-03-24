//
//  NetworkRepository.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

// This repository wraps the use case.
public class NetworkRepository {
    private let fetchDataUseCase: FetchDataUseCase
    
    // The parameter is public, so NetworkServiceProtocol must be public.
    public init(networkService: NetworkServiceProtocol) {
        self.fetchDataUseCase = FetchDataUseCase(networkService: networkService)
    }
    
    public func getData(from url: URL) async throws -> Data {
        return try await fetchDataUseCase.execute(url: url)
    }
}
