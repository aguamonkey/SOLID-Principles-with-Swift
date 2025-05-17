//
//  ReactiveGalacticExplorerView.swift
//  Open-Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Joshua Browne on 17/05/2025.
//

import Foundation
import SwiftUI

public struct ReactiveGalacticExplorerView: View {
    @StateObject private var viewModel: ReactiveExplorerViewModel

    public init(viewModel: ReactiveExplorerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        List(viewModel.entities, id: \.id) { entity in
            entity.makeView()
        }
        .navigationTitle("Live Galactic Explorer")
    }
}
