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
    private let networkRepository: NetworkRepositoryProtocol  // Protocol, not concrete!
    
    @Published public var fetchedData: Data?
    @Published public var errorMessage: String?
    @Published public var isLoading = false
    
    public init(networkRepository: NetworkRepositoryProtocol) {
        self.networkRepository = networkRepository
    }
    
    public func loadData(from url: URL) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let data = try await networkRepository.getData(from: url)
                self.fetchedData = data
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                self.fetchedData = nil
                LoggingService.shared.log("Error loading data: \(error.localizedDescription)", level: .error)
            }
        }
    }
}
