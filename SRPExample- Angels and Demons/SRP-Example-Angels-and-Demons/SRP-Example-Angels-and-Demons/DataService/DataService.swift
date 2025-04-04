//
//  DataService.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

// MARK: - Data Service

protocol DataServiceProtocol {
    func getAllAngels() async throws -> [AngelModel]
    func getAllDemons() async throws -> [DemonModel]
}

class DataService: DataServiceProtocol {
    // DataService is responsible for managing and supplying data related to angels and demons.
    // It adheres to SRP by centralizing data management, separate from UI logic.
    
    func getAllAngels() async throws -> [AngelModel] {
         // Simulate network latency.
         try await Task.sleep(nanoseconds: 500_000_000)
         return [
             AngelModel(name: "Michael", power: "Healing"),
             AngelModel(name: "Gabriel", power: "Messenger")
         ]
     }
     
     func getAllDemons() async throws -> [DemonModel] {
         try await Task.sleep(nanoseconds: 500_000_000)
         return [
             DemonModel(name: "Lucifer", ability: "Illusion"),
             DemonModel(name: "Mammon", ability: "Greed")
         ]
     }
}
