

import Combine
import Foundation
import Logger

enum NetworkError: Error {
    case invalidResponse
    case badResponse(statusCode: Int, errorText: String)
    case decodingFailed(Error)
}

//public typealias ResponseHandler = (URLSessionDataTask, URLResponse) -> Void

public protocol NetWorkAPI: AnyObject {
//    func request<T: Decodable>(
//        _ endpoint: URLRequest,
//        for type: T.Type,
//        jsonDecoder: JSONDecoder
//    ) async throws -> AsyncThrowingStream<T?, Error>

    func request<T: Decodable>(
        _ endpoint: URLRequest,
        for type: T.Type,
        decoder: JSONDecoder
    ) async -> Result<T, Error>
}

public extension NetWorkAPI {
    func request(
        _ endpoint: URLRequest
    ) async -> Result<Data, Error> {
        do {
            let (data, response) = try await URLSession.shared.data(for: endpoint)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }

            if httpResponse.statusCode == 200 {
                return .success(data)
            } else {
                return .failure(NetworkError.badResponse(statusCode: 400, errorText: "Bad response"))
            }
        } catch let eror {
            return .failure(eror)
        }
    }
}

public final class NetWorkLayer: NSObject, NetWorkAPI {

    var logger: Logger
    var session: URLSessionProtocol

    public init(
        logger: Logger,
        session: URLSessionProtocol = URLSessionWrapper()
    ) {
        self.session = session
        self.logger = logger
    }

    public func request<T>(
        _ endpoint: URLRequest,
        for type: T.Type,
        decoder: JSONDecoder
    ) async -> Result<T, any Error> where T: Decodable {
        do {
            let (data, response) = try await session.data(for: endpoint)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.invalidResponse)
            }

            if httpResponse.statusCode == 200 {
                let jsonObject = try JSONSerialization.jsonObject(
                    with: data,
                    options: []
                )

                logger.log(
                    level: .info,
                    message: "\(jsonObject)"
                )

                let decodedData = try JSONDecoder()
                    .decode(
                        T.self,
                        from: data
                    )
                return .success(decodedData)

            } else {
                return .failure(
                    NetworkError.badResponse(
                        statusCode: 400,
                        errorText: "Bad response"
                    )
                )
            }
        } catch let error as DecodingError {
            logger.log(
                level: .error,
                message: "❌ Failed to decode  with error: \(error.localizedDescription)"
            )
            return .failure(NetworkError.decodingFailed(error))
        } catch let eror {
            return .failure(eror)
        }
    }
}

extension NetWorkLayer: URLSessionTaskDelegate, URLSessionDataDelegate {
    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode != 200
        {
            // Handle non-200 status code
        }
        completionHandler(.allow)
    }
}
