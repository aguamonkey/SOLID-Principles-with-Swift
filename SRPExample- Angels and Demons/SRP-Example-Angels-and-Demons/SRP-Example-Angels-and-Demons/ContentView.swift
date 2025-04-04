//
//  ContentView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 12/12/2023.
//

import SwiftUI

// It adheres to SRP by focusing solely on the layout and navigation between these views.
// ContentView coordinates navigation between AngelListView and DemonListView.
struct ContentView: View {
    let dataService: DataServiceProtocol

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: AngelListView(dataService: dataService)) {
                    Text("View Angels")
                        .foregroundColor(.blue)
                        .padding()
                        .border(Color.blue)
                }
                
                NavigationLink(destination: DemonListView(dataService: dataService)) {
                    Text("View Demons")
                        .foregroundColor(.red)
                        .padding()
                        .border(Color.red)
                }
            }
            .navigationBarTitle("Angels and Demons")
        }
    }
}
