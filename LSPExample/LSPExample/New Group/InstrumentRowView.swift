//
//  InstrumentRowView.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import SwiftUI

struct InstrumentRowView: View {
    let info: InstrumentInfo
    let addAction: () -> Void

    var body: some View {
        HStack {
            Image(info.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(4)

            Text(info.name)
                .font(.body)
                .padding(.leading, 8)

            Spacer()

            // ▶︎ Play button
            Button {
                AudioService.shared.play(soundFileName: info.soundFileName)
            } label: {
                Image(systemName: "play.circle")
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 8)

            // ➕ Add button
            Button {
                addAction()
            } label: {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
}
