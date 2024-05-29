//
//  MessageViewModel.swift
//  
//
//  Created by Kevin on 4/17/24.
//

import Combine
import AVKit
@MainActor

final public class MessageViewModel: ObservableObject {
    @Published public var messages: [MessageRow] = []
    @Published public var messagesHelps: [MessageRow] = []
    @Published var inputMessage: String = ""
    @Published var isInteracting = false
    @Published var isShowingTips = false

    private let messageRepository: MessageRepository
    private var synthesizer: AVSpeechSynthesizer?
    var task: Task<Void, Never>?

    public init(
        messageRepository: MessageRepository
    ) {

        self.messageRepository = messageRepository
    }

    func helpAnswer(text: String) async {
        isInteracting = true
        messagesHelps = []
        var messageRow = MessageRow(
            isInteracting: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: "openai",
            response: .rawText(""),
            responseError: nil
        )

        self.messagesHelps.append(messageRow)
        do {
            let response = try await messageRepository.send(text: text)
            switch response {
            case .success(let meassage):
                let parsingTask = ResponseParsingTask()
                let output = await parsingTask.parse(text: meassage.content ?? "")
                messageRow.response = .attributed(output)
                isShowingTips = true
            case .failure(_):
                // TODO: handle error right here
                break

            }
//            print("numb ===>", messagesHelps.count)
        } catch  {
            print("got some error \(error)")
            // TODO: handle error right here
        }

        messageRow.isInteracting = false
        self.messagesHelps[self.messagesHelps.count - 1] = messageRow
        isInteracting = false
        isShowingTips = true
        speakLastResponse()
    }

    @MainActor
    func sendTapped() async  {
        self.task = Task {
            let text = inputMessage
            inputMessage = ""
            await sendMessageStream(text: text)
        }
    }

    func send(text: String) async  {

        isInteracting = true
        var messageRow = MessageRow(
            isInteracting: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: "openai",
            response: .rawText(""),
            responseError: nil
        )

        self.messages.append(messageRow)
        do {
            let response = try await messageRepository.send(text: text)
            switch response {
            case .success(let meassage):
                let parsingTask = ResponseParsingTask()
                let output = await parsingTask.parse(text: meassage.content ?? "")
                messageRow.response = .attributed(output)
            case .failure(_): 
                // TODO: handle error right here
                break

            }
        } catch  {
            print("got some error \(error)")
            // TODO: handle error right here
        }

        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
        speakLastResponse()
    }

    func sendMessageStream(text: String) async  {
        isInteracting = true
        var messageRow = MessageRow(
            isInteracting: true,
            sendImage: "profile",
            send: .rawText(text),
            responseImage: "openai",
            response: .rawText(""),
            responseError: nil
        )
        self.messages.append(messageRow)
        do {
            for try await value in await messageRepository.sendStream(text: text) {
                let parsingTask = ResponseParsingTask()
                let output = await parsingTask.parse(text: value.content ?? "")
                messageRow.response = .attributed(output)
                messageRow.isInteracting = false

            }
        } catch {
            let parsingTask = ResponseParsingTask()
            let output = await parsingTask.parse(text: error.localizedDescription)
            messageRow.response = .attributed(output)
            messageRow.isInteracting = false
        }

        messageRow.isInteracting = false
        self.messages[self.messages.count - 1] = messageRow
        isInteracting = false
        speakLastResponse()
    }


    func retry(message: MessageRow) async {
        self.task = Task {
            guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
                return
            }
            self.messages.remove(at: index)
            await send(text: message.sendText)
        }
    }

    func cancelStream() {
        task?.cancel()
    }

    func speakLastResponse() {
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance )
    }

    func stopSpeaking() {
        synthesizer?.stopSpeaking(at: .immediate)
    }

}
