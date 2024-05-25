import XCTest
import TestSupport
import OHHTTPStubs
import OHHTTPStubsSwift
import Logger
import NetWork

@testable import NetWork

final class NetWorkTests: XCTestCase {

    var sut: NetWorkAPI!

    private var urlRequest: URLRequest {
        let url = URL(string: "https://")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        return urlRequest
    }

    override func setUp() {
        super.setUp()

        let logger = Logger(label: "")
        sut =  NetWorkLayer(logger: logger)
    }

    override func tearDown() {
        super.tearDown()
        URLSessionMock.lastRequest = nil
        sut = nil
    }

    func testPostRequestSucess() async throws {

        stub(condition: isPath("/v1/chat/completions")) { request in
            let fetchPathCaseEmpty = Bundle.module.path(forResource: "request", ofType: "json")!
            return fixture(
                filePath: fetchPathCaseEmpty,
                headers: request.allHTTPHeaderFields
            )
        }

        let response =  await sut.request(
            urlRequest,
            for: MockStreamCompletionResponse.self,
            decoder: JSONDecoder()
        )

        if case .success(let data) = response {
            XCTAssertEqual(data.choices.first?.message.content, "Hello! How can I assist you today?")
            XCTAssertEqual(data.choices.first?.message.role, "assistant")
        }

    }

    func testPostFailse() async throws {
        stub(condition: isPath("/v1/chat/completions")) { request in
            let fetchPathCaseEmpty = Bundle.module.path(
                forResource: "invalid_request",
                ofType: "json"
            )!
            return fixture(
                filePath: fetchPathCaseEmpty,
                status: 400,
                headers: request.allHTTPHeaderFields
            )

        }

        let response =  await sut.request(
            urlRequest,
            for: MockStreamCompletionResponse.self,
            decoder: JSONDecoder()
        )
        if case .failure(let error) = response {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }


}

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


