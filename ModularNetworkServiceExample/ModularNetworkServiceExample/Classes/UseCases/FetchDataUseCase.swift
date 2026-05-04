//
//  FetchDataUseCase.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

public class FetchDataUseCase: FetchDataUseCaseProtocol {
    private let networkService: NetworkServiceProtocol
    private let logger: LoggingServiceProtocol
    
    public init(
        networkService: NetworkServiceProtocol,
        logger: LoggingServiceProtocol = LoggingService.shared
    ) {
        self.networkService = networkService
        self.logger = logger
    }
    
    public func execute(url: URL) async throws -> Data {
        logger.log("Executing fetch data use case for URL: \(url)", level: .debug)
        
        do {
            let data = try await networkService.fetchData(from: url)
            logger.log("Successfully fetched \(data.count) bytes", level: .info)
            return data
        } catch {
            logger.log("Failed to fetch data: \(error)", level: .error)
            throw error
        }
    }
}
