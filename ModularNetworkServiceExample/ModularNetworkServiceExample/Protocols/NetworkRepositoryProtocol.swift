//
//  NetworkRepositoryProtocol.swift
//  ModularNetworkServiceExample
//
//  Created by Joshua Browne on 07/06/2025.
//

import Foundation

public protocol NetworkRepositoryProtocol {
    func getData(from url: URL) async throws -> Data
}
