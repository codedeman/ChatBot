

import Foundation
import Combine
import Logger

enum NetworkError: Error {
    case invalidResponse
    case badResponse(statusCode: Int, errorText: String)
    case decodingFailed(Error)
}

public protocol NetWorkAPI: AnyObject {

    func request<T: Decodable>(
        _ endpoint: URLRequest,
        for type: T.Type,
        jsonDecoder: JSONDecoder
    ) async throws -> AsyncThrowingStream<T?, Error>


    func request<T: Decodable>(_ endpoint: URLRequest, for type: T.Type, decoder: JSONDecoder) async -> Result<T, Error>


}


final public class NetWorkLayer: NetWorkAPI {

    

    private let urlSession: URLSession
    private let logger: Logger // Assuming you have a logger implementation

    public init(
        urlSession: URLSession = .shared,
        logger: Logger
    ) {
        self.urlSession = urlSession
        self.logger = logger
    }

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
//                        try Task.checkCancellation()
                        print("line ====> ", line)
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {

                    print("wtf", error)
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


    public func request<T>(
        _ endpoint: URLRequest,
        for type: T.Type,
        decoder: JSONDecoder
    ) async -> Result<T, any Error> where T : Decodable {

        do {
            let (data, response) = try await URLSession.shared.data(for: endpoint)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if httpResponse.statusCode == 200 {
                print("response", httpResponse)

                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                print("json ==>", jsonData)

                let decodedData = try JSONDecoder()
                    .decode(
                        T.self,
                        from: data
                    )
                return .success(decodedData)
            } else {
                throw NetworkError.badResponse(
                    statusCode: 400,
                    errorText: "Bad response"
                )
            }
        } catch let eror  {
            return .failure((eror))
        }
    }

//    private func request(_ endpoint: EndPointType, completion: @escaping (Result<APIResponse, APIError>) -> Void) {
//        guard let request = buildURLRequest(from: endpoint) else {
//            completion(.failure(.invalidEndpoint))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            self?.logger.log(request: request, data: data, response: response as? HTTPURLResponse, error: error)
//
//            if let error = error {
//                completion(.failure(.networkError(error: error)))
//                return
//            }
//
//            guard let data = data, let httpResponse = response as? HTTPURLResponse,
//                  (200 ..< 400).contains(httpResponse.statusCode)
//            else {
//                completion(.failure(.badServerResponse))
//                return
//            }
//
//            completion(.success((data, httpResponse.statusCode)))
//        }
//
//        task.resume()
//    }

}
