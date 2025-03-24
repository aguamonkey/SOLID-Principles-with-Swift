//
//  RetryManager.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 24/03/2025.
//

import Foundation

struct RetryManager {
    /// Retries an asynchronous task for a maximum number of attempts with exponential backoff.
    /// - Parameters:
    ///   - maxRetries: The maximum number of retries.
    ///   - delay: The initial delay before retrying.
    ///   - task: The asynchronous task to execute.
    /// - Returns: The result of the task if successful.
    /// - Throws: The error from the task if all retries fail.
    static func retry<T>(maxRetries: Int = 3, delay: TimeInterval = 1.0, task: @escaping () async throws -> T) async throws -> T {
        var currentDelay = delay
        var attempts = 0
        while true {
            do {
                let result = try await task()
                return result
            } catch {
                attempts += 1
                if attempts >= maxRetries {
                    throw error
                }
                LoggingService.shared.log("Attempt \(attempts) failed, retrying in \(currentDelay) seconds...")
                try await Task.sleep(nanoseconds: UInt64(currentDelay * Double(NSEC_PER_SEC)))
                currentDelay *= 2
            }
        }
    }
}
