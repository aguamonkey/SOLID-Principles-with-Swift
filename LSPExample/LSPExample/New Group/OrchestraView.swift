//
//  OrchestraView.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation
import SwiftUI

// Views/OrchestraView.swift

struct OrchestraView: View {
    @ObservedObject var orchestraService = OrchestraService()

    var body: some View {
        VStack {
            Text("Orchestra Performance")
                .font(.headline)

            List(orchestraService.performConcert(), id: \.self) { sound in
                Text(sound)
            }
        }
        .onAppear(perform: setupOrchestra)
    }

    private func setupOrchestra() {
        // Replace the old manual adds with your JSON-driven factory:
        InstrumentInfoStore.all.forEach { info in
            let instrument = info.makePlayable()
            orchestraService.addInstrument(instrument)
        }
    }
}
