//
//  DataService.swift
//  SRP-Example-Angels-and-Demons
//
//  Created by Gobias LTD on 17/12/2023.
//

import Foundation

class DataService {
    // DataService is responsible for managing and supplying data related to angels and demons.
    // It adheres to SRP by centralizing data management, separate from UI logic.

    func getAllAngels() -> [AngelModel] {
        // Example implementation. In a real app, this might fetch data from a database or API.
        return [
            AngelModel(name: "Michael", power: "Healing"),
            AngelModel(name: "Gabriel", power: "Messenger")
            // Add more angels as needed
        ]
    }

    func getAllDemons() -> [DemonModel] {
        // Example implementation. Similar to angels, data can be fetched or hardcoded.
        return [
            DemonModel(name: "Lucifer", ability: "Illusion"),
            DemonModel(name: "Mammon", ability: "Greed")
            // Add more demons as needed
        ]
    }
}

