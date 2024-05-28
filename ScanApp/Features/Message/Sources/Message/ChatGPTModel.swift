//
//  ChatGPTModel.swift
//  
//
//  Created by Kevin on 4/19/24.
//

import UIKit

struct Message: Codable {
    let role: String
    let content: String
}

extension Array where Element == Message {

    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}


struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [Message]
    let stream: Bool
}

public struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

public struct StreamChoice: Decodable {
    let finishReason: String?
//    let delta: StreamMessage
    let message: StreamMessage

}

public struct StreamMessage: Decodable {
    let role: String?
    let content: String?

    public init(role: String?, contents: String?) {
        self.role = role
        self.content = contents
    }
    
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}


struct CompletionResponse: Decodable {
    let choices: [Choice]
    let usage: Usage?
}

struct Usage: Decodable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
}

struct Choice: Decodable {
    let message: Message
    let finishReason: String?
}
