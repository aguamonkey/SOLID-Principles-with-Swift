//
//  DataError.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

// Public error enum to be used throughout the domain.
public enum DataError: LocalizedError {
    case invalidResponse
    case noData
    case custom(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case .noData:
            return "No data received from the server."
        case .custom(let message):
            return message
        }
    }
}
