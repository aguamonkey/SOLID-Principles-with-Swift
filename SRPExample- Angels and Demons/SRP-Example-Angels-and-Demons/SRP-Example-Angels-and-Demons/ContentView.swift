//
//  ContentView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 12/12/2023.
//

import SwiftUI

// ContentView is responsible for coordinating the presentation of AngelListView and DemonListView.
// It adheres to SRP by focusing solely on the layout and navigation between these views.
struct ContentView: View {
    // Instance of DataService to fetch angel and demon data.
    let dataService = DataService()

    var body: some View {
        NavigationView {
            VStack {
                // Navigation link to AngelListView
                NavigationLink(destination: AngelListView(hierarchy: AngelHierarchy(rank: "Archangel", angels: dataService.getAllAngels()))) {
                    Text("View Angels")
                        .foregroundColor(.blue)
                        .padding()
                        .border(Color.blue)
                }

                // Navigation link to DemonListView
                NavigationLink(destination: DemonListView(hierarchy: DemonHierarchy(rank: "Greater Demon", demons: dataService.getAllDemons()))) {
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

// Preview for SwiftUI Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
