//
//  ContentView.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
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
                    .onAppear {
                        if let url = URL(string: "https://api.example.com/data") {
                            viewModel.loadData(from: url)
                        }
                    }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
