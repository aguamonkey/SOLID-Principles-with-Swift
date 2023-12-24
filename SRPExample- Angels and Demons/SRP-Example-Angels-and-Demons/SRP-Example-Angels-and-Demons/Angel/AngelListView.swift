//
//  AngelListView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

import SwiftUI


// AngelListView is responsible for displaying a list of angels.
// It adheres to SRP by handling only the presentation of AngelView instances within a list.
struct AngelListView: View {
    var hierarchy: AngelHierarchy


    var body: some View {
        List(hierarchy.angels, id: \.name) { angel in
            NavigationLink(destination: AngelDetailView(angel: angel)) {
                AngelView(angel: angel)
                // This view focuses solely on how angels are listed, delegating the angel representation to AngelView.
            }
            // Each angel in the list now has a navigation link to its detailed view.
        }
        .navigationBarTitle("Angels")
    }
}



// Preview for SwiftUI Canvas
struct AngelListView_Previews: PreviewProvider {
    static var previews: some View {
        AngelListView(hierarchy: AngelHierarchy(rank: "Archangel", angels: DataService().getAllAngels()))
    }
}
