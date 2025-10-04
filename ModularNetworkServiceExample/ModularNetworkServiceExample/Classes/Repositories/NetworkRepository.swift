//
//  NetworkRepository.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

public class NetworkRepository: NetworkRepositoryProtocol {
    private let fetchDataUseCase: FetchDataUseCaseProtocol
    
    // NOW expects FetchDataUseCaseProtocol, not NetworkServiceProtocol
    public init(fetchDataUseCase: FetchDataUseCaseProtocol) {
        self.fetchDataUseCase = fetchDataUseCase
    }
    
    public func getData(from url: URL) async throws -> Data {
        return try await fetchDataUseCase.execute(url: url)
    }
}
