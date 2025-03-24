//
//  ConfigManager.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

public class ConfigManager {
    public static let shared = ConfigManager()
    
    // For demonstration, we hardcode the endpoint.
    public let apiEndpoint: String
    
    private init() {
        // In a real-world scenario, load this from a configuration file.
        apiEndpoint = "https://api.example.com/data"
    }
}
