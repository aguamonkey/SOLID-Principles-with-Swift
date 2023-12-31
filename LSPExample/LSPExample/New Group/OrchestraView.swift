//
//  OrchestraView.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation
import SwiftUI

// Views/OrchestraView.swift

import SwiftUI

struct OrchestraView: View {
    @ObservedObject var orchestraService = OrchestraService()

    var body: some View {
        VStack {
            Text("Orchestra Performance")
                .font(.headline)
            List {
                ForEach(orchestraService.performConcert(), id: \.self) { sound in
                    Text(sound)
                }
            }
        }
        .onAppear {
            setupOrchestra()
        }
    }

    private func setupOrchestra() {
        // Make sure this function is adding instruments to the orchestra
        orchestraService.addInstrument(StringInstrument(name: "Violin"))
        orchestraService.addInstrument(WindInstrument(name: "Flute", reedType: "N/A"))
        orchestraService.addInstrument(BrassInstrument(name: "Trumpet", valveCount: 6))
        // Add more instruments here if needed
    }
}

