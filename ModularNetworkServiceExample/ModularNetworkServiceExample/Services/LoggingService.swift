//
//  LoggingService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

class LoggingService {
    static let shared = LoggingService()
    
    private init() {}
    
    func log(_ message: String) {
        // For production apps, you might integrate with a logging framework or remote monitoring.
        print("[LOG] \(message)")
    }
}
