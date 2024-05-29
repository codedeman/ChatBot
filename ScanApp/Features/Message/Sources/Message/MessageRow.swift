//
//  MessageRow.swift
//  
//
//  Created by Kevin on 4/16/24.
//

import UIKit
import CoreUI
public struct AttributedOutput {
    let string: String
    let results: [ParserResult]
}

public enum MessageRowType {
    case attributed(AttributedOutput)
    case rawText(String)

    public var text: String {
        switch self {
        case .attributed(let attributedOutput):
            return attributedOutput.string
        case .rawText(let string):
            return string
        }
    }
}

public struct MessageRow: Identifiable {

    public let id = UUID()

    public var isInteracting: Bool

    public let sendImage: String
    public var send: MessageRowType
    public var sendText: String {
        send.text
    }

    public let responseImage: String
    public var response: MessageRowType?
    public var responseText: String? {
        response?.text
    }

    public var responseError: String?

}

