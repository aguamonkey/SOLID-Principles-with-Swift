//
//  PollingEntityLoader.swift
//  OCPGalacticExplorer
//
//  Created by Gobias LTD on 2025-05-17.
//

import Foundation
import Combine

/// Protocol defining a streaming publisher of SpaceEntity arrays.
public protocol ReactiveSpaceEntityLoader {
    var entitiesPublisher: AnyPublisher<[any SpaceEntity], Error> { get }
}

/// Periodically polls an endpoint and emits updated entity lists.
public class PollingEntityLoader: ReactiveSpaceEntityLoader {
    public let entitiesPublisher: AnyPublisher<[any SpaceEntity], Error>

    public init(endpoint: URL, interval: TimeInterval = 60, registry: EntityRegistry) {
        let decoder = JSONDecoder()
        decoder.userInfo[.entityRegistry] = registry

        entitiesPublisher = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                URLSession.shared.dataTaskPublisher(for: endpoint)
                    .map(\.data)
                    // Decode into wrappers, then map to the real entities
                    .decode(type: [AnySpaceEntity].self, decoder: decoder)
                    .map { wrappers in wrappers.map { $0.entity } }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
