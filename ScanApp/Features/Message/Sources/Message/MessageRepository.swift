//
//  MessageRepository.swift
//  
//
//  Created by Kevin on 4/16/24.
//

import Foundation
import NetWork

public protocol MessageRepository {
    func send(text: String) async throws -> Result<StreamMessage, Error>
    func sendStream(text: String) async  -> AsyncThrowingStream<StreamMessage, Error>
}
public typealias ResponseHandler = (URLSessionDataTask, URLResponse) -> Void

final public class DBMessageRepository: NSObject, MessageRepository  {

    private let apiClientService: NetWorkAPI
    private var historyList = [Message]()
    private let systemMessage: Message = .init(role: "system", content: "")
    private let urlSession = URLSession.shared

    public init(
        apiClientService: NetWorkAPI
    ) {
        self.apiClientService = apiClientService
    }

    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()

    private let apiKey: String = ""
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }

    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }

    private func jsonBody(
        text: String,
        stream: Bool = true
    ) throws -> Data {
        let request = Request(
            model: "gpt-3.5-turbo",
            temperature:  0.5,
            messages: generateMessages(from: text),
            stream: stream
        )
        return try JSONEncoder().encode(request)
    }

    private func generateMessages(from text: String) -> [Message] {
        var messages = [systemMessage] + historyList + [Message(role: "user", content: text)]
        if messages.contentCount > (4000 * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
         return messages
    }

    private func appendToHistoryList(
        userText: String,
        responseText: String
    ) {
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
    }

    public func send(text: String) async throws -> Result<StreamMessage, any Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody =  try jsonBody(
            text: text,
            stream: false
        )

        let response =  await apiClientService.request(
            urlRequest,
            for: StreamCompletionResponse.self,
            decoder: JSONDecoder()
        )

        switch response {
        case .success(let response):
            print("==>", response.choices.count)
            if let message = response
                .choices
                .last?
                .message {
                return .success(message)
            }
            return .failure(Error.self as! Error)
        case .failure(let error):
            return .failure(error)
        }

    }

    public func sendStream(text: String) async -> AsyncThrowingStream<StreamMessage, Error> {

        var urlRequest = self.urlRequest
        do {
            urlRequest.httpBody =  try jsonBody(
                text: text,
                stream: false
            )

        } catch {
            print("error url", error)
        }

        let response = await apiClientService.request(
            urlRequest,
            for: StreamCompletionResponse.self,
            decoder: JSONDecoder()
        )

        return AsyncThrowingStream(StreamMessage.self) { configuration in
            switch response {
            case .success(let result):
                if let message = result
                    .choices
                    .last?
                    .message {
                    configuration.yield(message)
                }
                configuration.finish()
            case .failure(let error):
                configuration.finish(throwing: error)
            }
        }

    }


}

extension String: CustomNSError {

    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}

