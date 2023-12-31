//
//  InstrumentSelectionView.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation
// Views/InstrumentSelectionView.swift

import SwiftUI

struct InstrumentSelectionView: View {
    @ObservedObject var orchestraService: OrchestraService

    var body: some View {
        VStack {
            Text("Select Instruments")
                .font(.headline)
            // Example instrument selection buttons
            Button("Add Violin") {
                orchestraService.addInstrument(StringInstrument(name: "Violin"))
            }
            Button("Add Flute") {
                orchestraService.addInstrument(WindInstrument(name: "Flute", reedType: "Woodwind"))
            }
            // Add more buttons for different instruments
        }
    }
}
