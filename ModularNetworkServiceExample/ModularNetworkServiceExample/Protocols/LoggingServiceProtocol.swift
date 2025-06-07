//
//  LoggingServiceProtocol.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 07/06/2025.
//

import Foundation

public protocol LoggingServiceProtocol {
    func log(_ message: String, level: LogLevel)
}
