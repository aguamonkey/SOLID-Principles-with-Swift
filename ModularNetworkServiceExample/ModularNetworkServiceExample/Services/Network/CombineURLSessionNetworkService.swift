//
//  CombineURLSessionNetworkService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation
import Combine

class CombineURLSessionNetworkService {
    func fetchData(from url: URL) -> AnyPublisher<Data, Error> {
        LoggingService.shared.log("Fetching data via Combine from \(url.absoluteString)")
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let httpResponse = result.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    LoggingService.shared.log("Failed fetching data via Combine from \(url.absoluteString)")
                    throw URLError(.badServerResponse)
                }
                LoggingService.shared.log("Successfully fetched data via Combine from \(url.absoluteString)")
                return result.data
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
