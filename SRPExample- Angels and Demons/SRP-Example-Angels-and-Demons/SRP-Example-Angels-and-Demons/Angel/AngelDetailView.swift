//
//  AngelDetailView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation
import SwiftUI

// AngelDetailView is responsible for presenting detailed information about a specific angel.
// It adheres to SRP by focusing solely on the detail presentation of an Angel.
struct AngelDetailView: View {
    var angel: AngelModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name: \(angel.name)")
                .font(.title)
            Text("Power: \(angel.power)")
                .font(.body)
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .navigationBarTitle("Angel Details", displayMode: .inline)
    }
}

// Preview for SwiftUI Canvas
struct AngelDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AngelDetailView(angel: AngelModel(name: "Michael", power: "Healing"))
    }
}
