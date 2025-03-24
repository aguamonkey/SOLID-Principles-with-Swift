//
//  AsyncURLSessionNetworkService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

class AsyncURLSessionNetworkService: NetworkServiceProtocol {
    func fetchData(from url: URL) async throws -> Data {
        LoggingService.shared.log("Fetching data from \(url.absoluteString)")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            LoggingService.shared.log("Failed fetching data from \(url.absoluteString) with bad response.")
            throw URLError(.badServerResponse)
        }
        
        LoggingService.shared.log("Successfully fetched data from \(url.absoluteString)")
        return data
    }
}
