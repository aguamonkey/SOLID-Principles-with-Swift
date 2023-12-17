//
//  AngelView.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

// AngelView is responsible solely for the UI representation of an Angel. It does not manage the Angel's data or behaviors."

import Foundation

import SwiftUI

// AngelView is responsible only for the UI representation of an Angel.
// It does not manage the Angel's data or behaviors, adhering to SRP.
struct AngelView: View {
    var angel: AngelModel

    var body: some View {
        VStack {
            Text(angel.name)
                .font(.largeTitle)
                .foregroundColor(.white)
            Text(angel.describePower())
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
    }
}
