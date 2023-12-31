//
//  OrchestraPerformanceView.swift
//  LSPExample
//
//  Created by Gobias LTD on 31/12/2023.
//

import Foundation

// Views/OrchestraPerformanceView.swift

import SwiftUI

struct OrchestraPerformanceView: View {
    @ObservedObject var orchestraService: OrchestraService

    var body: some View {
        VStack {
            Text("Orchestra Performance")
                .font(.headline)
            List(orchestraService.instruments) { instrument in
                Text(instrument.play())
            }
        }
    }
}
