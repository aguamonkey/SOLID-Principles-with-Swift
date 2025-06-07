//
//  FetchDataUseCase.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

public class FetchDataUseCase: FetchDataUseCaseProtocol {
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func execute(url: URL) async throws -> Data {
        LoggingService.shared.log("Executing fetch data use case for URL: \(url)", level: .debug)
        
        do {
            let data = try await networkService.fetchData(from: url)
            LoggingService.shared.log("Successfully fetched \(data.count) bytes", level: .info)
            return data
        } catch {
            LoggingService.shared.log("Failed to fetch data: \(error)", level: .error)
            throw error
        }
    }
}
