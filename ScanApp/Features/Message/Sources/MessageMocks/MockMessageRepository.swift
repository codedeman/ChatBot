//
//  MockMessageRepository.swift
//  
//
//  Created by Kevin on 4/24/24.
//


import NetWork
import Message

final public class MockMessageRepository: MessageRepository {

    public func sendStream(text: String) async -> AsyncThrowingStream<Message.StreamMessage, any Error> {
        return AsyncThrowingStream(StreamMessage.self)  { configuration in
            configuration.yield(
                StreamMessage.init(
                    role: "assistant",
                    contents: "How can i help you today "
                )
            )
        }
    }
    

    private var isSuccess: Bool = false

    public init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    public func send(text: String) async throws -> Result<Message.StreamMessage, any Error> {
        if isSuccess {
            return .success(
                .init(
                    role: "assistant",
                    contents: "How can i help you today"
                )
            )
        } else {
            return .failure(Error.self as! Error)
        }

    }

}
