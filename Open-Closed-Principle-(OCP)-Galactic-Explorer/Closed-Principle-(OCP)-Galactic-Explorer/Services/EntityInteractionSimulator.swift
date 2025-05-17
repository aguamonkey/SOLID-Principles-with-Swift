//
//  EntityInteractionSimulator.swift
//  OCPGalacticExplorer
//
//  Created by Gobias LTD on 2025-05-17.
//

import Foundation

/// A simple demonstration service that knows how to “interact” any two SpaceEntity instances
/// without ever needing to be modified when you add new entity types.
public class EntityInteractionSimulator {
  
  /// Simulate some generic interaction (e.g. gravitational, collision, etc.)
  /// - Returns: A human-readable summary string.
  public func simulateInteraction(between entity1: any SpaceEntity,
                                  and entity2: any SpaceEntity) -> String
  {
    return "Simulating a generic interaction between \(entity1.name) and \(entity2.name)."
  }
}
