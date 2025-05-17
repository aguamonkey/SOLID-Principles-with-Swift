
//  Created by Joshua Browne on 17/05/2025.
//

//
//  ExplorerViewModel.swift
//  OCPGalacticExplorer
//

import Foundation

@MainActor
public class ExplorerViewModel: ObservableObject {
    @Published public private(set) var entities: [any SpaceEntity] = []

    private let loader: SpaceEntityDataLoader

    public init(loader: SpaceEntityDataLoader) {
        self.loader = loader
        print("[ViewModel] Initialized with loader:", type(of: loader))
    }

    /// One‐off fetch of entities, with debug prints
    public func fetch() async {
        print("[ViewModel] Starting fetch…")
        do {
            let result = try await loader.loadEntities()
            print("[ViewModel] Loaded \(result.count) entities:", result.map { $0.name })
            entities = result
        } catch {
            print("[ViewModel] ❌ Error loading entities:", error)
            entities = []
        }
    }
}

