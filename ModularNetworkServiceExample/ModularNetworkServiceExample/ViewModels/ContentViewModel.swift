//
//  ContentViewModel.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//


import Foundation
import SwiftUI

@MainActor
public class ContentViewModel: ObservableObject {
    private let networkRepository: NetworkRepositoryProtocol
    private let logger: LoggingServiceProtocol
    
    @Published public var fetchedData: Data?
    @Published public var errorMessage: String?
    @Published public var isLoading = false
    
    public init(
        networkRepository: NetworkRepositoryProtocol,
        logger: LoggingServiceProtocol = LoggingService.shared
    ) {
        self.networkRepository = networkRepository
        self.logger = logger
    }
    
    public func loadData(from url: URL) {
        Task {
            await loadDataAsync(from: url)
        }
    }
    
    public func loadDataAsync(from url: URL) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await networkRepository.getData(from: url)
            self.fetchedData = data
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.fetchedData = nil
            logger.log("Error loading data: \(error.localizedDescription)", level: .error)
        }
    }
}
