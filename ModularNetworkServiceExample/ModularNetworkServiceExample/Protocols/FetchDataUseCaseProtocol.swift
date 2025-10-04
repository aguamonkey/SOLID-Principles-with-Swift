//
//  FetchDataUseCaseProtocol.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 07/06/2025.
//

import Foundation

public protocol FetchDataUseCaseProtocol {
    func execute(url: URL) async throws -> Data
}

