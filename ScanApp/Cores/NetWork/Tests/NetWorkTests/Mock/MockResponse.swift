//
//  MockResponse.swift
//  
//
//  Created by Kevin on 5/25/24.
//

struct MockResponse: Decodable {
    let key: String
}

public struct MockStreamCompletionResponse: Decodable {
    let choices: [MockStreamChoice]
}

public struct MockStreamChoice: Decodable {
    let finishReason: String?
    let message: StreamMessage
}

public struct StreamMessage: Decodable {
    let role: String?
    let content: String?

    public init(
        role: String?,
        content: String?
    ) {
        self.role = role
        self.content = content
    }

}
