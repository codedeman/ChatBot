import XCTest
import MessageMocks
@testable import Message
@MainActor

final class MessageTests: XCTestCase {
    
    var sut: MessageViewModel!
    override  func setUp() {
        super.setUp()
        sut = .init(messageRepository: MockMessageRepository(isSuccess: true))
    }

    override  func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testStringExtension() {
        let originalString = "Hello, world!"
        XCTAssertEqual(String(originalString.reversed()), "!dlrow ,olleH")
    }


    func testSendMessage() async throws {

        // When
        sut.inputMessage = "Hello my friend"
        // Given
        await sut.sendTapped()

        if let firtSentence = self.sut.messages.first?.responseText, let secondSentence = self.sut.messages.first?.responseText {
            XCTAssertEqual(firtSentence, "Hello my friend") // Then
            XCTAssertEqual(secondSentence, "How can i help you today") // Then
        }

    }


}
