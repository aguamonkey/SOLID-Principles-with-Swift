//
//  LoggingService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case error = "ERROR"
}

public class LoggingService {
    public static let shared = LoggingService()
    
    private init() {}
    
    public func log(_ message: String, level: LogLevel = .debug) {
        print("[\(level.rawValue)] \(message)")
    }
}

