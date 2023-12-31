//
//  ContentView.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import SwiftUI

// Views/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var orchestraService = OrchestraService()

    var body: some View {
        TabView {
            InstrumentSelectionView(orchestraService: orchestraService)
                .tabItem {
                    Label("Select", systemImage: "plus.circle")
                }
            OrchestraPerformanceView(orchestraService: orchestraService)
                .tabItem {
                    Label("Perform", systemImage: "music.note")
                }
        }
    }
}
