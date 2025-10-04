//
//  MockNetworkService.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 07/06/2025.
//

import Foundation

public class MockNetworkService: NetworkServiceProtocol {
    public var shouldFail = false
    public var mockData = Data("Mock data".utf8)
    
    public init() {}
    
    public func fetchData(from url: URL) async throws -> Data {
        if shouldFail {
            throw DataError.custom("Mock network error")
        }
        return mockData
    }
}
