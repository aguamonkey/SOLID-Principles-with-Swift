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
    private var loadingTask: Task<Void, Never>?
    private var activeLoadID: UUID?

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

    @discardableResult
    public func loadData(from url: URL) -> Task<Void, Never> {
        loadingTask?.cancel()

        let task = Task {
            await loadDataAsync(from: url)
        }
        loadingTask = task
        return task
    }

    public func loadDataAsync(from url: URL) async {
        let loadID = UUID()
        activeLoadID = loadID
        isLoading = true

        defer {
            if activeLoadID == loadID {
                isLoading = false
                loadingTask = nil
                activeLoadID = nil
            }
        }

        do {
            let data = try await networkRepository.getData(from: url)
            guard !Task.isCancelled, activeLoadID == loadID else { return }
            self.fetchedData = data
            self.errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            guard activeLoadID == loadID else { return }
            self.errorMessage = error.localizedDescription
            self.fetchedData = nil
            logger.log("Error loading data: \(error.localizedDescription)", level: .error)
        }
    }
}
