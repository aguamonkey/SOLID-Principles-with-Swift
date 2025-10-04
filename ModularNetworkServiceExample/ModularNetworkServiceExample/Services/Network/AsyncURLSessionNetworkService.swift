//
//  AsyncURLSessionNetworkService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

// Make sure the class and its initializer are public.
public class AsyncURLSessionNetworkService: NetworkServiceProtocol {
    public init() {}
    
    public func fetchData(from url: URL) async throws -> Data {
        LoggingService.shared.log("Fetching data from \(url.absoluteString)", level: .info)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate response.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            LoggingService.shared.log("Bad response for URL \(url.absoluteString)", level: .error)
            throw DataError.invalidResponse
        }
        guard !data.isEmpty else {
            LoggingService.shared.log("No data returned for URL \(url.absoluteString)", level: .error)
            throw DataError.noData
        }
        
        LoggingService.shared.log("Data fetched successfully from \(url.absoluteString)", level: .info)
        return data
    }
}


