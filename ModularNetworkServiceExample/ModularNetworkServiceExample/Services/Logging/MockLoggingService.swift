//
//  MockLoggingService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 07/06/2025.
//

import Foundation

public class MockLoggingService: LoggingServiceProtocol {
    public var loggedMessages: [(message: String, level: LogLevel)] = []
    
    public init() {}
    
    public func log(_ message: String, level: LogLevel) {
        loggedMessages.append((message, level))
    }
}
