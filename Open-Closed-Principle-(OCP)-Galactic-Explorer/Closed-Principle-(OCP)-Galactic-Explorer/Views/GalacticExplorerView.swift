//
//  GalacticExplorerView.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//


import SwiftUI

public struct GalacticExplorerView: View {
    @StateObject private var viewModel: ExplorerViewModel

    public init(viewModel: ExplorerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        List(viewModel.entities, id: \.id) { entity in
            entity.makeView()
        }
        .onAppear {
            Task { await viewModel.fetch() }
        }
        .navigationTitle("Galactic Explorer")
    }
}
