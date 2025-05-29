//
//  InstrumentInfo.swift
//  LSPExample
//
//  Created by Joshua Browne on 29/05/2025.
//

import Foundation

/// Holds all the static info you need to display/play an instrument.

struct InstrumentInfo: Identifiable, Decodable {
  let id: UUID
  let name: String
  let imageName: String
  let soundFileName: String

  /// Build a concrete `Playable` from this metadata.
  func makePlayable() -> Playable {
    switch name {
    case "Violin":
      return StringInstrument(id: id, name: name)
    case "Flute":
      // note: reedType comes from metadata if you want, or hard-code “Woodwind”
      return WindInstrument(id: id, name: name, reedType: "Woodwind")
    case "Trumpet":
      // again, you could put valveCount in your JSON if you like
      return BrassInstrument(id: id, name: name, valveCount: 3)
    default:
      // fallback to a generic string instrument
      return StringInstrument(id: id, name: name)
    }
  }
}
