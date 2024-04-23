//
//  ParserResult.swift
//  
//
//  Created by Kevin on 4/23/24.
//

import UIKit

public struct ParserResult: Identifiable {
    public let id = UUID()
    public let attributedString: AttributedString
    public let isCodeBlock: Bool
    public let codeBlockLanguage: String?
}
