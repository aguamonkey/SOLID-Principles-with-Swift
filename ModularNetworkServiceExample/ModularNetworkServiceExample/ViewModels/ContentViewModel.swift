//
//  ContentViewModel.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    private let networkService: NetworkServiceProtocol
    
    @Published var fetchedData: Data?
    @Published var errorMessage: String?
    
    init(networkService: NetworkServiceProtocol = AsyncURLSessionNetworkService()) {
        self.networkService = networkService
    }
    
    func loadData(from url: URL) {
        Task {
            do {
                // Using RetryManager to attempt the fetch multiple times if needed.
                let data = try await RetryManager.retry {
                    try await self.networkService.fetchData(from: url)
                }
                self.fetchedData = data
            } catch {
                self.errorMessage = error.localizedDescription
                LoggingService.shared.log("Error loading data: \(error.localizedDescription)")
            }
        }
    }
}
