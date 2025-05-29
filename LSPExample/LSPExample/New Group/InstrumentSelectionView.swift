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

      List(InstrumentInfoStore.all) { info in
        InstrumentRowView(info: info) {
          // <-- create the real instrument here:
          let playable = info.makePlayable()
          orchestraService.addInstrument(playable)
        }
      }
    }
  }
}
