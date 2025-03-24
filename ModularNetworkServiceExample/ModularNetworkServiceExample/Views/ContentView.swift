//
//  ContentView.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import SwiftUI

// The SwiftUI view that uses the view model from DI.
public struct ContentView: View {
    // Resolve the view model via our DI container.
    @StateObject private var viewModel: ContentViewModel = DIContainer.shared.resolve(ContentViewModel.self)
    
    public init() {}
    
    public var body: some View {
        VStack {
            if let data = viewModel.fetchedData {
                Text("Data loaded: \(data.count) bytes")
                    .font(.headline)
                    .padding()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Loading...")
                    .padding()
                    .onAppear {
                        if let url = URL(string: ConfigManager.shared.apiEndpoint) {
                            viewModel.loadData(from: url)
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
