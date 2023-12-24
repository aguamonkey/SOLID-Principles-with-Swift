//
//  ContentView.swift
//  Closed-Principle-(OCP)-Galactic-Explorer
//
//  Created by Gobias LTD on 23/12/2023.
//

import SwiftUI

struct ContentView: View {
    // Instance of SpaceEntityLoader to fetch space entities.
    let entityLoader = SpaceEntityLoader()
    // Instance of EntityInteractionSimulator to demonstrate interactions.
    let interactionSimulator = EntityInteractionSimulator()

    @State private var interactionResult: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(entityLoader.loadEntities(), id: \.name) { entity in
                        SpaceEntityView(entity: entity)
                    }
                }
                .navigationBarTitle("Galactic Explorer")
                .toolbar {
                    // Example of triggering an interaction simulation.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Simulate Interaction") {
                            simulateInteraction()
                        }
                    }
                }
                // Displaying the result of the interaction simulation
                if !interactionResult.isEmpty {
                    Text("Interaction Result: \(interactionResult)")
                        .padding()
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private func simulateInteraction() {
        let entities = entityLoader.loadEntities()
        if entities.count >= 2 {
            // Simulating interaction between the first two entities for demonstration
            interactionResult = interactionSimulator.simulateInteraction(between: entities[0], and: entities[1])
        } else {
            interactionResult = "Not enough entities for interaction simulation."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
