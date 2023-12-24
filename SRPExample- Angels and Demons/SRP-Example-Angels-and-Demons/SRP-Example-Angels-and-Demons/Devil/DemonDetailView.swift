//
//  DemonDetailView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

// DemonDetailView is responsible for presenting detailed information about a specific demon.
// It maintains SRP by focusing exclusively on the detail presentation of a Demon.
struct DemonDetailView: View {
    var demon: DemonModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name: \(demon.name)")
                .font(.title)
            Text("Ability: \(demon.ability)")
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationBarTitle("Demon Details", displayMode: .inline)
    }
}

// Preview for SwiftUI Canvas
struct DemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DemonDetailView(demon: DemonModel(name: "Lucifer", ability: "Illusion"))
    }
}
