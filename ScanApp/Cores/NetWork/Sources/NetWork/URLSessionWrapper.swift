//
//  URLSessionWrapper.swift
//  
//
//  Created by Kevin on 5/25/24.
//

import UIKit

final public class URLSessionWrapper: URLSessionProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await session.data(for: request)
    }
}
