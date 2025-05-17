//
//  ReactiveExplorerViewModel.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation
import Combine

@MainActor
public class ReactiveExplorerViewModel: ObservableObject {
    @Published public private(set) var entities: [any SpaceEntity] = []
    private var cancellables = Set<AnyCancellable>()

    public init(loader: ReactiveSpaceEntityLoader) {
        loader.entitiesPublisher
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$entities)
    }
}
