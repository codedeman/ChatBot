////
////  File.swift
////  
////
////  Created by Kevin on 5/15/24.
////

import Foundation

extension NetWorkLayer {

    public func request<T: Decodable>(
        _ endpoint: URLRequest,
        for type: T.Type,
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) async throws -> AsyncThrowingStream<T?, Error> {
        let (asyncBytes, response) = try await urlSession.bytes(for: endpoint)
        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            let errorText = "Bad Response: \(httpResponse.statusCode)"
            logger.log(level: .trace, message: "Failed to read response: \(errorText)")
//            try Task.checkCancellation()
            throw NetworkError.badResponse(statusCode: httpResponse.statusCode, errorText: errorText)
        }
        _ = ""
        let streams: AsyncThrowingStream<String, Error> = AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in asyncBytes.lines {
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {
                    logger.log(level: .trace, message: "Failed to use stream: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }
        return AsyncThrowingStream { [weak self] continuation in
            Task {
                do {
                    for try await line in streams {
                        try Task.checkCancellation()
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? jsonDecoder.decode(T.self, from: data) {
                            try continuation.yield(response)
                        }
                    }
                    continuation.finish()
                } catch {
                    logger.log(level: .trace, message: "Failed to use stream: \(error)")
                    continuation.finish(throwing: error)
                }
            }
        }

    }
}

public protocol URLSessionProtocol {
     func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

class URLSessionMock: URLSessionProtocol {
    static var mockResponse: (Data, URLResponse)?
    static var lastRequest: URLRequest?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        URLSessionMock.lastRequest = request
        guard let mockResponse = URLSessionMock.mockResponse else {
            throw URLError(.badServerResponse)
        }
        return mockResponse
    }
}
