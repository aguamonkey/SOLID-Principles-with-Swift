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
        // Register the network service for NetworkServiceProtocol.
        register(NetworkServiceProtocol.self) { _ in
            AsyncURLSessionNetworkService()
        }
        
        // Register the repository.
        register(NetworkRepository.self) { container in
            let networkService = container.resolve(NetworkServiceProtocol.self)
            return NetworkRepository(networkService: networkService)
        }
        
        // Register the view model.
        register(ContentViewModel.self) { container in
            let repository = container.resolve(NetworkRepository.self)
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
