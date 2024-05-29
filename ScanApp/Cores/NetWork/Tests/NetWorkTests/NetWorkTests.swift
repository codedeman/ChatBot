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

    //MARK: HTTP method

    func testGetMethod() async throws {
        // Stub GET request
        stub(condition: isMethodGET() && isHost("example.com")) { _ in
            let stubData = Data()
            return HTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
        }

        let url = URL(string: "https://example.com/get")!
        let request = URLRequest(url: url)

        let _: Result<MockResponse, Error> = await sut.request(request, for: MockResponse.self, decoder: JSONDecoder())

        XCTAssertEqual(request.httpMethod, "GET")
    }

    func testPostMethod() async throws {
        // Stub POST request
        stub(condition: isMethodPOST() && isHost("example.com")) { _ in
            let stubData = Data()
            return HTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
        }

        var request = URLRequest(url: URL(string: "https://example.com/post")!)
        request.httpMethod = "POST"

        let _: Result<MockResponse, Error> = await sut.request(request, for: MockResponse.self, decoder: JSONDecoder())

        XCTAssertEqual(request.httpMethod, "POST")
    }

    func testPutMethod() async throws {
        // Stub PUT request
        stub(condition: isMethodPUT() && isHost("example.com")) { _ in
            let stubData = Data()
            return HTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
        }

        var request = URLRequest(url: URL(string: "https://example.com/put")!)
        request.httpMethod = "PUT"

        let _: Result<MockResponse, Error> = await sut.request(request, for: MockResponse.self, decoder: JSONDecoder())

        XCTAssertEqual(request.httpMethod, "PUT")
    }

    func testDeleteMethod() async throws {
           // Stub DELETE request
           stub(condition: isMethodDELETE() && isHost("example.com")) { _ in
               let stubData = Data()
               return HTTPStubsResponse(data: stubData, statusCode: 200, headers: nil)
           }

           var request = URLRequest(url: URL(string: "https://example.com/delete")!)
           request.httpMethod = "DELETE"

           let _: Result<MockResponse, Error> = await sut.request(request, for: MockResponse.self, decoder: JSONDecoder())

           XCTAssertEqual(request.httpMethod, "DELETE")
       }

}



