//
//  DevilView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import SwiftUI

// DemonView's sole responsibility is the UI representation of a Demon.
// It remains unaware of the underlying data or behaviors of a Demon.
struct DemonView: View {
    var demon: DemonModel

    var body: some View {
        VStack {
            Text(demon.name)
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(demon.describeAbility())
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.red)
        .cornerRadius(10)
    }
}

