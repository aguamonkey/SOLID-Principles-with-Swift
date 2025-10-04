//
//  DIContainer.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

@MainActor
public class DIContainer {
    public static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    
    private init() {
        registerDependencies()
    }
    
    @MainActor
    private func registerDependencies() {
        // Register network service (concrete implementation)
        register(NetworkServiceProtocol.self) { _ in
            AsyncURLSessionNetworkService()
        }
        
        // Register use case (concrete implementation with protocol dependency)
        register(FetchDataUseCaseProtocol.self) { container in
            let networkService = container.resolve(NetworkServiceProtocol.self)
            return FetchDataUseCase(networkService: networkService)
        }
        
        // Register repository (concrete implementation with protocol dependency)
        register(NetworkRepositoryProtocol.self) { container in
            let useCase = container.resolve(FetchDataUseCaseProtocol.self)
            return NetworkRepository(fetchDataUseCase: useCase)
        }
        
        // Register view model (concrete with protocol dependency)
        register(ContentViewModel.self) { container in
            let repository = container.resolve(NetworkRepositoryProtocol.self)
            return ContentViewModel(networkRepository: repository)
        }
    }
    
    @MainActor
    public func register<Service>(_ serviceType: Service.Type, factory: @escaping (DIContainer) -> Service) {
        let key = "\(serviceType)"
        services[key] = factory
    }
    
    @MainActor
    public func resolve<Service>(_ serviceType: Service.Type) -> Service {
        let key = "\(serviceType)"
        guard let factory = services[key] as? (DIContainer) -> Service else {
            fatalError("No registered dependency for \(serviceType)")
        }
        return factory(self)
    }
}
