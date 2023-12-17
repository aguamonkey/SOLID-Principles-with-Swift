//
//  DevilListView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

// DemonListView is responsible for displaying a list of demons.
// It maintains SRP by focusing only on the presentation of DemonView instances.
struct DemonListView: View {
    var hierarchy: DemonHierarchy
    
    var body: some View {
        List(hierarchy.demons, id: \.name) { demon in
            NavigationLink(destination: DemonDetailView(demon: demon)) {
                DemonView(demon: demon)
                // Similar to AngelListView, this view is concerned only with listing demons, using DemonView for individual demon representation.
            }
            // Each demon in the list is linked to its detailed view.
        }
        .navigationBarTitle("Demons")
    }
}

// Preview for SwiftUI Canvas
struct DemonListView_Previews: PreviewProvider {
    static var previews: some View {
        DemonListView(hierarchy: DemonHierarchy(rank: "Greater Demon", demons: DataService().getAllDemons()))
    }
}

