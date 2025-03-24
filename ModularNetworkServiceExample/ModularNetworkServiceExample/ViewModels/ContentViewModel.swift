//
//  ContentViewModel.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//
import Foundation
import SwiftUI

@MainActor
// Public view model for the presentation layer.
public class ContentViewModel: ObservableObject {
    private let networkRepository: NetworkRepository
    
    @Published public var fetchedData: Data?
    @Published public var errorMessage: String?
    
    // Ensure the initializer’s parameter label matches the DI registration.
    public init(networkRepository: NetworkRepository) {
        self.networkRepository = networkRepository
    }
    
    public func loadData(from url: URL) {
        Task {
            do {
                let data = try await networkRepository.getData(from: url)
                self.fetchedData = data
            } catch {
                self.errorMessage = error.localizedDescription
                LoggingService.shared.log("Error loading data: \(error.localizedDescription)", level: .error)
            }
        }
    }
}
